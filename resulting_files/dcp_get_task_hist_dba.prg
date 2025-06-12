CREATE PROGRAM dcp_get_task_hist:dba
 RECORD reply(
   1 create_dt_tm = dq8
   1 hist_cnt = i4
   1 qual_hist[*]
     2 task_id = f8
     2 task_status_cd = f8
     2 task_status_disp = vc
     2 task_status_mean = c12
     2 task_dt_tm = dq8
     2 task_status_reason_cd = f8
     2 task_status_reason_disp = vc
     2 task_status_reason_mean = c12
     2 updt_dt_tm = dq8
     2 reschedule_reason_cd = dq8
     2 reschedule_date_time = dq8
     2 reschedule_reason_disp = vc
     2 reschedule_reason_mean = c12
     2 updt_id = f8
     2 updt_person = vc
     2 task_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt1 = 0
 SET task_act_cnt = 0
 SELECT INTO "nl:"
  FROM task_action ta
  WHERE (ta.task_id=request->task_id)
  DETAIL
   task_act_cnt = (task_act_cnt+ 1)
  WITH nocounter
 ;end select
 IF (task_act_cnt=0)
  SELECT INTO "nl:"
   FROM task_activity ta,
    prsnl p
   PLAN (ta
    WHERE (ta.task_id=request->task_id))
    JOIN (p
    WHERE ta.updt_id=p.person_id)
   DETAIL
    cnt1 = (cnt1+ 1)
    IF (cnt1 > size(reply->qual_hist,5))
     stat = alterlist(reply->qual_hist,(cnt1+ 10))
    ENDIF
    reply->create_dt_tm = ta.task_create_dt_tm, reply->qual_hist[cnt1].task_id = ta.task_id, reply->
    qual_hist[cnt1].task_status_cd = ta.task_status_cd,
    reply->qual_hist[cnt1].task_dt_tm = ta.task_dt_tm, reply->qual_hist[cnt1].updt_dt_tm = ta
    .updt_dt_tm, reply->qual_hist[cnt1].task_status_reason_cd = ta.task_status_reason_cd,
    reply->qual_hist[cnt1].reschedule_reason_cd = ta.reschedule_reason_cd, reply->qual_hist[cnt1].
    updt_id = ta.updt_id, reply->qual_hist[cnt1].updt_person = p.name_full_formatted
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual_hist,cnt1)
  SET reply->hist_cnt = cnt1
 ELSEIF (task_act_cnt > 0)
  SELECT INTO "nl:"
   FROM task_activity ta,
    prsnl p
   PLAN (ta
    WHERE (ta.task_id=request->task_id))
    JOIN (p
    WHERE ta.updt_id=p.person_id)
   DETAIL
    cnt1 = (cnt1+ 1)
    IF (cnt1 > size(reply->qual_hist,5))
     stat = alterlist(reply->qual_hist,(cnt1+ 10))
    ENDIF
    reply->create_dt_tm = ta.task_create_dt_tm, reply->qual_hist[cnt1].task_id = ta.task_id, reply->
    qual_hist[cnt1].task_status_cd = ta.task_status_cd,
    reply->qual_hist[cnt1].task_dt_tm = ta.task_dt_tm, reply->qual_hist[cnt1].updt_dt_tm = ta
    .updt_dt_tm, reply->qual_hist[cnt1].task_status_reason_cd = ta.task_status_reason_cd,
    reply->qual_hist[cnt1].reschedule_reason_cd = ta.reschedule_reason_cd, reply->qual_hist[cnt1].
    updt_id = ta.updt_id, reply->qual_hist[cnt1].updt_person = p.name_full_formatted
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual_hist,cnt1)
  SET reply->hist_cnt = cnt1
  SELECT INTO "nl:"
   FROM task_action ta,
    prsnl p
   PLAN (ta
    WHERE (ta.task_id=request->task_id))
    JOIN (p
    WHERE ta.updt_id=p.person_id)
   ORDER BY ta.updt_dt_tm DESC
   DETAIL
    cnt1 = (cnt1+ 1)
    IF (cnt1 > size(reply->qual_hist,5))
     stat = alterlist(reply->qual_hist,(cnt1+ 10))
    ENDIF
    reply->qual_hist[cnt1].task_id = ta.task_id, reply->qual_hist[cnt1].task_status_cd = ta
    .task_status_cd, reply->qual_hist[cnt1].task_status_cd = ta.task_status_cd,
    reply->qual_hist[cnt1].task_dt_tm = ta.task_dt_tm, reply->qual_hist[cnt1].updt_dt_tm = ta
    .updt_dt_tm, reply->qual_hist[cnt1].task_status_reason_cd = ta.task_status_reason_cd,
    reply->qual_hist[cnt1].reschedule_reason_cd = ta.reschedule_reason_cd, reply->qual_hist[cnt1].
    reschedule_date_time = ta.task_dt_tm, reply->qual_hist[cnt1].task_tz = validate(ta.task_tz,0),
    reply->qual_hist[cnt1].updt_id = ta.updt_id, reply->qual_hist[cnt1].updt_person = p
    .name_full_formatted
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual_hist,cnt1)
  SET reply->hist_cnt = cnt1
 ENDIF
 FOR (i = 1 TO reply->hist_cnt)
   CALL echo(build("task_id = ",reply->qual_hist[i].task_id))
   CALL echo(build("task_status = ",reply->qual_hist[i].task_status_cd))
   CALL echo(build("reschedule_dt_tm = ",format(reply->qual_hist[i].reschedule_date_time,";;q")))
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
