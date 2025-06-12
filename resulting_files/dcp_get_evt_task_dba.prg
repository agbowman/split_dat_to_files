CREATE PROGRAM dcp_get_evt_task:dba
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ta.task_id
  FROM task_activity ta,
   task_activity_assignment taa
  PLAN (ta
   WHERE (ta.task_activity_cd=request->task_activity_cd)
    AND (ta.event_id=request->event_id)
    AND ta.active_ind=1)
   JOIN (taa
   WHERE ta.task_id=taa.task_id
    AND (taa.assign_prsnl_id=request->assign_prsnl_id)
    AND taa.active_ind=1
    AND taa.beg_eff_dt_tm <= cnvtdatetime(sysdate)
    AND taa.end_eff_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   reply->task_id = ta.task_id, reply->updt_cnt = ta.updt_cnt
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
