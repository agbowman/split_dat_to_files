CREATE PROGRAM dcp_del_nomen_category:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 DELETE  FROM dcp_nomencategorydef def
  WHERE (def.category_id=request->category_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_nomencategory dnc
  WHERE (dnc.category_id=request->category_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "orm_del_nomen_category"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to delete"
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
