CREATE PROGRAM dcp_get_new_result:dba
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ta.task_id
  FROM task_activity ta,
   task_activity_assignment taa
  PLAN (ta
   WHERE (ta.task_activity_cd=request->task_activity_cd)
    AND (ta.task_status_cd=request->task_status_cd)
    AND (ta.person_id=request->person_id)
    AND ta.active_ind=1)
   JOIN (taa
   WHERE ta.task_id=taa.task_id
    AND (taa.assign_prsnl_id=request->assign_prsnl_id)
    AND taa.active_ind=1
    AND taa.beg_eff_dt_tm <= cnvtdatetime(sysdate)
    AND taa.end_eff_dt_tm > cnvtdatetime(sysdate))
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
