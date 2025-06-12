CREATE PROGRAM dcp_del_mtt_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DELETE  FROM message_type_template_reltn mtt
  WHERE (mtt.message_type_cd=request->message_type_cd)
   AND (mtt.template_id=request->template_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "MESSAGE_TYPE_TEMPLATE RELTN"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
