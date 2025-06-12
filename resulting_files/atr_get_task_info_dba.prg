CREATE PROGRAM atr_get_task_info:dba
 RECORD reply(
   1 task_number = i4
   1 description = vc
   1 active_dt_tm = dq8
   1 active_ind = i2
   1 inactive_dt_tm = dq8
   1 optional_required_flag = i2
   1 text = vc
   1 subordinate_task_ind = i2
   1 app_group_cd = f8
   1 app_authorization_level = i4
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  t.task_number, t.description, t.active_dt_tm,
  t.active_ind, t.inactive_dt_tm, t.text,
  t.subordinate_task_ind, t.updt_cnt, nullind_t_active_dt_tm = nullind(t.active_dt_tm),
  nullind_t_inactive_dt_tm = nullind(t.inactive_dt_tm)
  FROM application_task t
  WHERE (request->task_number=t.task_number)
  HEAD REPORT
   reply->app_authorization_level = 100
  DETAIL
   reply->task_number = t.task_number, reply->description = t.description, reply->text = t.text,
   reply->active_dt_tm =
   IF (nullind_t_active_dt_tm=0) cnvtdatetime(t.active_dt_tm)
   ENDIF
   , reply->inactive_dt_tm =
   IF (nullind_t_inactive_dt_tm=0) cnvtdatetime(t.inactive_dt_tm)
   ENDIF
   , reply->optional_required_flag = t.optional_required_flag,
   reply->active_ind = t.active_ind, reply->subordinate_task_ind = t.subordinate_task_ind, reply->
   updt_cnt = t.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
