CREATE PROGRAM dcp_get_task_stat_count:dba
 DECLARE complete = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE stat_priority = f8 WITH constant(uar_get_code_by("MEANING",4010,"STAT"))
 DECLARE now_priority = f8 WITH constant(uar_get_code_by("MEANING",4010,"NOW"))
 DECLARE count = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM task_activity ta
  WHERE (ta.order_id=request->order_id)
   AND ta.task_status_cd=complete
   AND ((ta.task_priority_cd=stat_priority) OR (ta.task_priority_cd=now_priority))
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->task_list,5))
    stat = alterlist(reply->task_list,(count+ 5))
   ENDIF
   reply->task_list[count].task_id = ta.task_id
  FOOT REPORT
   stat = alterlist(reply->task_list,count)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
