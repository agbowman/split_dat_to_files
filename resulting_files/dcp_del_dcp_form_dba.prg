CREATE PROGRAM dcp_del_dcp_form:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DELETE  FROM dcp_forms_def dfd
  WHERE (dfd.dcp_forms_ref_id=request->dcp_forms_ref_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_forms_ref dfr
  WHERE (dfr.dcp_forms_ref_id=request->dcp_forms_ref_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
