CREATE PROGRAM dcp_del_apache_ref:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DELETE  FROM risk_adjustment_location ral
  WHERE (ral.risk_adjustment_ref_id=request->risk_adjustment_ref_id)
  WITH nocounter
 ;end delete
 DELETE  FROM risk_adjustment_ref rar
  WHERE (rar.risk_adjustment_ref_id=request->risk_adjustment_ref_id)
  WITH nocounter
 ;end delete
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
