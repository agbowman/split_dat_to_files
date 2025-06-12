CREATE PROGRAM dcp_del_query_patient_list:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DELETE  FROM dcp_pl_query_list dpql
  WHERE (dpql.patient_list_id=request->patient_list_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 DELETE  FROM dcp_pl_query_value dpqv
  WHERE (dpqv.patient_list_id=request->patient_list_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
