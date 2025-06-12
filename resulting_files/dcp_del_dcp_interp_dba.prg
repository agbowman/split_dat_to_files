CREATE PROGRAM dcp_del_dcp_interp:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DELETE  FROM dcp_interp_state s
  WHERE (s.dcp_interp_id=request->dcp_interp_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_interp_component ic
  WHERE (ic.dcp_interp_id=request->dcp_interp_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_interp i
  WHERE (i.dcp_interp_id=request->dcp_interp_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reqinfo->commit_ind = 1
END GO
