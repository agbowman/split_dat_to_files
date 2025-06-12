CREATE PROGRAM cdi_document_check_out:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 blob_handle = vc
    1 ax_appid = f8
    1 ax_docid = f8
    1 no_resume = i2
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 checkout_success_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 resume_own_check_out_ind = i2
  )
 ENDIF
 SET reply->resume_own_check_out_ind = 0
 SET reply->status_data.status = "Z"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_document_check_out"
 DECLARE checkoutuserid = f8 WITH protect, noconstant(0.0)
 DECLARE lastcheckoutdttm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE lock_expiration_dt_tm = dq8 WITH protect, constant(cnvtlookbehind(build(2,",H"),cnvtdatetime
   (sysdate)))
 SUBROUTINE (updatecheckout(checked_out_user_id=f8) =i2)
   UPDATE  FROM cdi_document_checkout cdc
    SET cdc.person_id = reqinfo->updt_id, cdc.checkout_dt_tm = cnvtdatetime(sysdate), cdc
     .updt_applctx = reqinfo->updt_applctx,
     cdc.updt_cnt = (cdc.updt_cnt+ 1), cdc.updt_dt_tm = cnvtdatetime(sysdate), cdc.updt_id = reqinfo
     ->updt_id,
     cdc.updt_task = reqinfo->updt_task
    WHERE (cdc.blob_handle=request->blob_handle)
     AND (cdc.ax_appid=request->ax_appid)
     AND (cdc.ax_docid=request->ax_docid)
     AND cdc.person_id=checked_out_user_id
    WITH nocounter
   ;end update
   IF (curqual != 1)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SELECT INTO "nl:"
  FROM cdi_document_checkout cdc
  WHERE (cdc.blob_handle=request->blob_handle)
   AND (cdc.ax_appid=request->ax_appid)
   AND (cdc.ax_docid=request->ax_docid)
  DETAIL
   checkoutuserid = cdc.person_id, lastcheckoutdttm = cdc.checkout_dt_tm
  WITH nocounter
 ;end select
 IF (checkoutuserid=0.0)
  INSERT  FROM cdi_document_checkout cdc
   SET cdc.cdi_document_checkout_id = seq(cdi_seq,nextval), cdc.person_id = reqinfo->updt_id, cdc
    .blob_handle = request->blob_handle,
    cdc.ax_appid = request->ax_appid, cdc.ax_docid = request->ax_docid, cdc.checkout_dt_tm =
    cnvtdatetime(sysdate),
    cdc.updt_applctx = reqinfo->updt_applctx, cdc.updt_cnt = 0, cdc.updt_dt_tm = cnvtdatetime(sysdate
     ),
    cdc.updt_id = reqinfo->updt_id, cdc.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual != 1)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Failed to add row to cdi_document_checkout."
   GO TO exit_script
  ENDIF
  SET reqinfo->commit_ind = 1
  SET reply->checkout_success_ind = 1
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Successfully added row to cdi_document_checkout."
 ELSEIF ((checkoutuserid=reqinfo->updt_id))
  SET reqinfo->commit_ind = 0
  IF ((request->no_resume=1))
   SET reply->checkout_success_ind = 0
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Document is already checked out by this user."
  ELSE
   IF (updatecheckout(checkoutuserid))
    SET reqinfo->commit_ind = 1
    SET reply->checkout_success_ind = 1
    SET reply->resume_own_check_out_ind = 1
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Resuming checkout by this user."
   ELSE
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to update row on cdi_document_checkout."
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->checkout_success_ind = 0
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Document is already checked out by another user."
  IF (lastcheckoutdttm < lock_expiration_dt_tm)
   IF (updatecheckout(checkoutuserid))
    SET reqinfo->commit_ind = 1
    SET reply->checkout_success_ind = 1
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Successfully updated row on cdi_document_checkout."
   ELSE
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to update row on cdi_document_checkout."
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
