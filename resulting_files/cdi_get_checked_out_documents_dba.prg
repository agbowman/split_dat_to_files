CREATE PROGRAM cdi_get_checked_out_documents:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 ax_appid = f8
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 document[*]
      2 blob_handle = vc
      2 ax_appid = f8
      2 ax_docid = f8
      2 username = vc
      2 name_full_formatted = vc
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
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_checked_out_documents"
 DECLARE documentcount = i4 WITH noconstant(- (1))
 SELECT
  IF ((request->ax_appid > 0))
   PLAN (cdc
    WHERE (request->ax_appid=cdc.ax_appid)
     AND (cdc.person_id != reqinfo->updt_id))
    JOIN (p
    WHERE p.person_id=cdc.person_id)
  ELSE
   PLAN (cdc
    WHERE (cdc.person_id != reqinfo->updt_id))
    JOIN (p
    WHERE p.person_id=cdc.person_id)
  ENDIF
  INTO "nl:"
  cdc.blob_handle, cdc.ax_appid, cdc.ax_docid,
  p.username, p.name_full_formatted
  FROM cdi_document_checkout cdc,
   prsnl p
  HEAD REPORT
   documentcount = 0
  DETAIL
   IF (cdc.person_id != 0)
    documentcount += 1
    IF (mod(documentcount,10)=1)
     stat = alterlist(reply->document,(documentcount+ 9))
    ENDIF
    reply->document[documentcount].blob_handle = cdc.blob_handle, reply->document[documentcount].
    ax_appid = cdc.ax_appid, reply->document[documentcount].ax_docid = cdc.ax_docid,
    reply->document[documentcount].username = p.username, reply->document[documentcount].
    name_full_formatted = p.name_full_formatted
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->document,documentcount)
  WITH nocounter
 ;end select
 IF (documentcount=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No documents are checked out"
 ELSEIF (curqual=0)
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "List of blob handles for checked out documents returned"
 ENDIF
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].operationname = "select"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_checked_out_documents"
#exit_script
 IF ((reply->status_data.status != "S")
  AND (reply->status_data.status != "Z"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_checked_out_documents"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to get checked out documents"
 ENDIF
END GO
