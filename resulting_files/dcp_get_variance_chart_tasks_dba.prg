CREATE PROGRAM dcp_get_variance_chart_tasks:dba
 RECORD reply(
   1 task_cnt = i4
   1 task_qual[*]
     2 reference_task_id = f8
     2 task_description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET task_cnt = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET chart_variance_cd = 0.0
 SET code_set = 6027
 SET cdf_meaning = "CHART VARIAN"
 EXECUTE cpm_get_cd_for_cdf
 SET chart_variance_cd = code_value
 SELECT INTO "nl:"
  ot.reference_task_id, ot.active_ind, ot.task_description_key
  FROM order_task ot
  WHERE ot.task_activity_cd=chart_variance_cd
   AND ot.active_ind=1
  ORDER BY ot.task_description_key
  DETAIL
   task_cnt = (task_cnt+ 1)
   IF (task_cnt > size(reply->task_qual,5))
    stat = alterlist(reply->task_qual,(task_cnt+ 5))
   ENDIF
   reply->task_qual[task_cnt].reference_task_id = ot.reference_task_id, reply->task_qual[task_cnt].
   task_description = ot.task_description
  WITH nocounter
 ;end select
 SET reply->task_cnt = task_cnt
 SET stat = alterlist(reply->task_qual,task_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
