CREATE PROGRAM dcp_del_key_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 DELETE  FROM template_keyword_reltn rt
  WHERE (rt.template_keyword_reltn_id=request->template_keyword_reltn_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET failed = "T"
  SET cs_table = "TEMPLATE_KEYWORD_RELTN"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = cs_table
 ENDIF
END GO
