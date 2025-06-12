CREATE PROGRAM dcp_monitor_query_list:dba
 RECORD reply(
   1 execution_status_cd = f8
   1 execution_status_disp = vc
   1 execution_status_mean = vc
   1 execution_dt_tm = dq8
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
 SELECT INTO "nl:"
  FROM dcp_pl_query_list dpql
  PLAN (dpql
   WHERE (dpql.patient_list_id=request->patient_list_id))
  DETAIL
   reply->execution_status_cd = dpql.execution_status_cd, reply->execution_dt_tm = dpql
   .execution_dt_tm
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
