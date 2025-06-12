CREATE PROGRAM dcp_del_purge_criteria:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DELETE  FROM tl_purge_criteria pc
  WHERE (pc.tl_purge_id=request->purge_criteria_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "tl_purge_criteria table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to delete from table"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_add_purge_criteria"
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
