CREATE PROGRAM dcp_del_dcp_form_all:dba
 RECORD reply(
   1 status_data
     2 status = c1
 )
 SET reply->status_data.status = "F"
 SET count = 0
 UPDATE  FROM order_task ot
  SET ot.dcp_forms_ref_id = 0
  WHERE (ot.dcp_forms_ref_id=request->dcp_forms_ref_id)
  WITH nocounter
 ;end update
 UPDATE  FROM dcp_forms_activity dfa
  SET active_ind = 0
  WHERE (dfa.dcp_forms_ref_id=request->dcp_forms_ref_id)
  WITH nocounter
 ;end update
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
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
