CREATE PROGRAM daf_icd9_remove_text_wrapper:dba
 RECORD reply(
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((validate(daf_icd9_request->text_find_detail_id,- (99.0))=- (99.0)))
  FREE RECORD daf_icd9_request
  RECORD daf_icd9_request(
    1 text_find_detail_id = f8
    1 parent_log_id = f8
    1 find_category = vc
  )
 ENDIF
 IF (validate(daf_icd9_reply->status,"Q")="Q")
  FREE RECORD daf_icd9_reply
  RECORD daf_icd9_reply(
    1 status = vc
    1 message = vc
  )
 ENDIF
 SET daf_icd9_request->text_find_detail_id = request->detail_id
 SET daf_icd9_request->parent_log_id = request->parent_log_id
 SET daf_icd9_request->find_category = "ICD9"
 EXECUTE dm_remove_text
 CALL echo("Echoing out the reply:")
 CALL echorecord(daf_icd9_reply)
 IF ((daf_icd9_reply->status="S"))
  SET reply->status_data.status = "S"
  SET reply->message = daf_icd9_reply->message
 ELSEIF ((daf_icd9_reply->status="F"))
  SET reply->status_data.status = "F"
  SET reply->message = daf_icd9_reply->message
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "DAF_ICD9_REMOVE_TEXT_WRPR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DM_REMOVE_TEXT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = daf_icd9_reply->message
 ELSE
  IF (size(trim(daf_icd9_reply->message,3),1) > 0)
   SET reply->status_data.status = "Z"
   SET reply->message = "No usable status value was returned."
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationname = "DAF_ICD9_CCL_WRAPPER"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DM_TXTFND_LOAD_DET"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = daf_icd9_reply->message
  ELSE
   SET reply->status_data.status = "F"
   SET reply->message = "No status information was returned by DM_TXTFND_LOAD_DET."
  ENDIF
 ENDIF
#exit_script
END GO
