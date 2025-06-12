CREATE PROGRAM ct_chg_doc2:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET doupdate = 0
 SET false = 0
 SET true = 1
 SET reply->status_data.status = "F"
 SET curupdtcnt = 0
 CALL echo(build("Request->ct_document_id = ",request->ct_document_id))
 SET cnta = 0
 SET doupdate = false
 SELECT INTO "nl:"
  doc.*
  FROM ct_document doc
  WHERE (doc.ct_document_id=request->ct_document_id)
  DETAIL
   cnta = (cnta+ 1), curupdtcnt = doc.updt_cnt
  WITH nocounter, forupdate(doc)
 ;end select
 IF (cnta=1)
  IF ((curupdtcnt != request->updt_cnt))
   SET reply->status_data.status = "C"
   SET doupdate = false
  ELSE
   SET doupdate = true
  ENDIF
 ELSE
  SET reply->status_data.status = "L"
  SET doupdate = false
 ENDIF
 CALL echo(build("curqual = ",curqual))
 IF (doupdate=true)
  SET doupdate = false
  UPDATE  FROM ct_document doc
   SET doc.begin_effective_dt_tm =
    IF ((request->docbegin != 0)) cnvtdatetime(request->docbegin)
    ELSE doc.begin_effective_dt_tm
    ENDIF
    , doc.end_effective_dt_tm =
    IF ((request->docend != 0)) cnvtdatetime(request->docend)
    ELSE doc.end_effective_dt_tm
    ENDIF
    , doc.title =
    IF ((request->title != "")) request->title
    ELSE doc.title
    ENDIF
    ,
    doc.description =
    IF ((request->description != "")) request->description
    ELSE doc.description
    ENDIF
    , doc.document_type_cd =
    IF ((request->document_type_cd != 0.0)) request->document_type_cd
    ELSE doc.document_type_cd
    ENDIF
    , doc.prot_amendment_id =
    IF ((request->prot_amendment_id != 0.0)) request->prot_amendment_id
    ELSE doc.prot_amendment_id
    ENDIF
    ,
    doc.updt_cnt = (doc.updt_cnt+ 1), doc.updt_applctx = reqinfo->updt_applctx, doc.updt_task =
    reqinfo->updt_task,
    doc.updt_id = reqinfo->updt_id, doc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (doc.ct_document_id=request->ct_document_id)
   WITH nocounter
  ;end update
  IF (curqual=1)
   SET doupdate = true
  ELSE
   SET doupdate = false
  ENDIF
  CALL echo(build("curqual =  ",curqual))
 ENDIF
 SET reqinfo->commit_ind = doupdate
 IF (doupdate=true)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Reply->status_data->status = ",reply->status_data.status))
END GO
