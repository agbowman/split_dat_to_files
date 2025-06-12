CREATE PROGRAM cdi_document_check_in:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 blob_handle = vc
    1 ax_appid = f8
    1 ax_docid = f8
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE lock_expiration_days = i4 WITH protect, constant(2)
 SET reply->status_data.status = "Z"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_document_check_in"
 DELETE  FROM cdi_document_checkout
  WHERE cdi_document_checkout_id > 0.0
   AND checkout_dt_tm < cnvtdatetime((curdate - lock_expiration_days),curtime3)
  WITH maxqual(cdi_document_checkout,1000)
 ;end delete
 DELETE  FROM cdi_document_checkout cdc
  WHERE (cdc.blob_handle=request->blob_handle)
   AND (cdc.person_id=reqinfo->updt_id)
   AND (cdc.ax_appid=request->ax_appid)
   AND (cdc.ax_docid=request->ax_docid)
  WITH nocounter
 ;end delete
 IF (curqual=1)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed to delete row from cdi_document_checkout."
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
