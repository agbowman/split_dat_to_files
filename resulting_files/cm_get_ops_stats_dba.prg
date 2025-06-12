CREATE PROGRAM cm_get_ops_stats:dba
 FREE RECORD reply
 RECORD reply(
   1 inproc_cnt = i4
   1 ip_list[*]
     2 cgname = c40
     2 cgid = i4
     2 jobname = c40
     2 jobid = i4
     2 stepname = c40
     2 schparmid = i4
     2 elapsed_time = i4
   1 scg_cnt = i4
   1 stask_cnt = i4
   1 sjstep_cnt = i4
   1 age_old_msg = i4
   1 msg_wait_cnt = i4
   1 msg_list[*]
     2 cgname = c40
     2 cgid = i4
     2 jobname = c40
     2 jobid = i4
     2 stepname = c40
     2 schparmid = i4
     2 elapsed_time = i4
     2 message = c100
   1 cgcount = i4
   1 cg_list[*]
     2 cgname = c40
     2 cgid = i4
     2 scgid = i4
     2 status = c40
     2 server_id = i4
     2 updt_dttm = dq8
     2 error_cnt = i4
     2 thr_exceed = i4
     2 thresh_list[*]
       3 thresh_type = i4
       3 jobid = i4
       3 jobname = c40
       3 schparmid = i4
       3 stepname = c40
       3 percent = i4
       3 elapsed_time = i4
     2 skip_cnt = i4
     2 wait_dep = i4
     2 job_cnt = i4
     2 job_list[*]
       3 jobname = c40
       3 jobid = i4
       3 sjobid = i4
       3 parentid = i4
       3 status = c40
       3 update_dttm = dq8
       3 sched_dttm = dq8
       3 start_dttm = dq8
       3 end_dttm = dq8
       3 sched_min = i4
       3 step_cnt = i4
       3 step_list[*]
         4 step_name = c40
         4 step_num = i4
         4 schparm_id = i4
         4 sstep_id = i4
         4 sjob_id = i4
         4 status = c40
         4 event_data = c100
         4 update_dttm = dq8
         4 start_dttm = dq8
         4 end_dttm = dq8
     2 jgrp_cnt = i4
     2 jgrp_list[*]
       3 jgname = c40
       3 jgid = i4
       3 sjgid = i4
       3 status = c40
       3 update_dttm = dq8
       3 sched_dttm = dq8
       3 start_dttm = dq8
       3 end_dttm = dq8
       3 sched_min = i4
       3 job_cnt = i4
       3 job_list[*]
         4 jobname = c40
         4 jobid = i4
         4 sjobid = i4
         4 parentid = i4
         4 time_ind = i4
         4 status = c40
         4 update_dttm = dq8
         4 sched_dttm = dq8
         4 start_dttm = dq8
         4 end_dttm = dq8
         4 sched_min = i4
         4 step_cnt = i4
         4 step_list[*]
           5 step_name = c40
           5 step_num = i4
           5 schparm_id = i4
           5 sstep_id = i4
           5 sjob_id = i4
           5 status = c40
           5 update_dttm = dq8
           5 event_data = c100
           5 start_dttm = dq8
           5 end_dttm = dq8
   1 cvstag = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->cvstag = "$Name: ver4_1_20030314 $"
 SET errmsg = fillstring(132," ")
 SET error_code = 0
 SET error_check = error(errmsg,1)
 SET reply->status_data.status = "F"
 SET count3 = 0
 SET count2 = 0
 SET count1 = 0
 SET count = 0
 SET cgcount = 0
 SET scgcount = 0
 SET taskcount = 0
 SET stepcount = 0
 SELECT INTO "nl:"
  FROM ops_schedule_control_group scg
  WHERE scg.ops_schedule_control_grp_id > 0
  DETAIL
   scgcount = (scgcount+ 1)
  WITH nocounter
 ;end select
 SET reply->scg_cnt = scgcount
 SELECT INTO "nl:"
  FROM ops_schedule_task st
  WHERE st.ops_schedule_task_id > 0
  DETAIL
   taskcount = (taskcount+ 1)
  WITH nocounter
 ;end select
 SET reply->stask_cnt = taskcount
 SELECT INTO "nl:"
  FROM ops_schedule_job_step js
  WHERE js.ops_schedule_job_step_id > 0
  DETAIL
   stepcount = (stepcount+ 1)
  WITH nocounter
 ;end select
 SET reply->sjstep_cnt = stepcount
 SET count = 0
 SET stat = 0
 SET host = cnvtupper(request->host)
 SELECT INTO "nl:"
  FROM ops_control_group cg
  WHERE cg.host=host
   AND cg.ops_control_grp_id > 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->cg_list,count), reply->cg_list[count].cgname = cg.name,
   reply->cg_list[count].cgid = cg.ops_control_grp_id, reply->cg_list[count].scgid = 0
   IF (cg.active_ind=1)
    reply->cg_list[count].status = "NOT INITIALIZED"
   ELSE
    reply->cg_list[count].status = "DELETE PENDING"
   ENDIF
   reply->cg_list[count].updt_dttm = 0, reply->cg_list[count].error_cnt = 0, reply->cg_list[count].
   server_id = cg.server_number
  WITH nocounter
 ;end select
 SET reply->cgcount = count
 SET count = 0
 SELECT INTO "nl:"
  scg.ops_schedule_control_group_id
  FROM code_value cv,
   ops_schedule_control_group scg,
   (dummyt d  WITH seq = value(reply->cgcount))
  PLAN (d)
   JOIN (scg
   WHERE scg.schedule_dt_tm=cnvtdatetimeutc(cnvtdatetime(cnvtdate(request->query_time),0),2)
    AND (scg.ops_control_grp_id=reply->cg_list[d.seq].cgid))
   JOIN (cv
   WHERE cv.code_value=scg.status_cd)
  HEAD scg.ops_schedule_control_grp_id
   count = (count+ 1), reply->cg_list[d.seq].scgid = scg.ops_schedule_control_grp_id
   IF (scg.empty_ind=1)
    reply->cg_list[d.seq].status = "EMPTY"
   ELSE
    reply->cg_list[d.seq].status = cv.cdf_meaning
   ENDIF
   reply->cg_list[d.seq].updt_dttm = cnvtdatetimeutc(scg.updt_dt_tm,2)
  WITH nocounter
 ;end select
 SET mycount = count
 IF (mycount > 0)
  SET count = 0
  SELECT INTO "nl:"
   FROM ops_schedule_task st,
    ops_task t,
    ops_schedule_job_step js,
    ops_job_step s,
    ops_schedule_param sp,
    code_value cv,
    (dummyt d  WITH seq = value(mycount))
   PLAN (d)
    JOIN (cv
    WHERE cv.cdf_meaning="INPROCESS")
    JOIN (st
    WHERE (st.ops_schedule_control_grp_id=reply->cg_list[d.seq].scgid))
    JOIN (t
    WHERE st.ops_task_id=t.ops_task_id)
    JOIN (js
    WHERE js.ops_schedule_task_id=st.ops_schedule_task_id
     AND cv.code_value=js.status_cd)
    JOIN (s
    WHERE js.ops_job_step_id=s.ops_job_step_id)
    JOIN (sp
    WHERE sp.ops_job_step_id=s.ops_job_step_id
     AND sp.ops_task_id=t.ops_task_id)
   ORDER BY d.seq
   HEAD js.ops_schedule_job_step_id
    count = (count+ 1), stat = alterlist(reply->ip_list,count)
   FOOT  js.ops_schedule_job_step_id
    reply->ip_list[count].cgname = reply->cg_list[d.seq].cgname, reply->ip_list[count].cgid = reply->
    cg_list[d.seq].cgid, reply->ip_list[count].jobname = st.name,
    reply->ip_list[count].jobid = t.ops_task_id, reply->ip_list[count].stepname = s.step_name, reply
    ->ip_list[count].schparmid = sp.ops_schedule_param_id,
    reply->ip_list[count].elapsed_time = datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(js
      .beg_effective_dt_tm),5)
   WITH nocounter
  ;end select
  SET reply->inproc_cnt = count
  SET count = 0
  SET oldmsg = 0
  SET tempoldmsg = 0
  SELECT INTO "nl:"
   FROM ops_schedule_task st,
    ops_task t,
    ops_schedule_job_step js,
    ops_job_step s,
    ops_schedule_param sp,
    code_value cv,
    (dummyt d  WITH seq = value(mycount))
   PLAN (d)
    JOIN (cv
    WHERE cv.cdf_meaning="MESSAGE")
    JOIN (st
    WHERE (st.ops_schedule_control_grp_id=reply->cg_list[d.seq].scgid))
    JOIN (t
    WHERE st.ops_task_id=t.ops_task_id)
    JOIN (js
    WHERE js.ops_schedule_task_id=st.ops_schedule_task_id
     AND cv.code_value=js.status_cd)
    JOIN (s
    WHERE js.ops_job_step_id=s.ops_job_step_id)
    JOIN (sp
    WHERE sp.ops_job_step_id=s.ops_job_step_id
     AND sp.ops_task_id=t.ops_task_id)
   ORDER BY d.seq
   HEAD js.ops_schedule_job_step_id
    count = (count+ 1), stat = alterlist(reply->msg_list,count), tempoldmsg = datetimediff(
     cnvtdatetime(curdate,curtime3),cnvtdatetime(js.beg_effective_dt_tm),5)
    IF (tempoldmsg > oldmsg)
     oldmsg = tempoldmsg
    ENDIF
   FOOT  js.ops_schedule_job_step_id
    reply->msg_list[count].cgname = reply->cg_list[d.seq].cgname, reply->msg_list[count].cgid = reply
    ->cg_list[d.seq].cgid, reply->msg_list[count].jobname = st.name,
    reply->msg_list[count].jobid = t.ops_task_id, reply->msg_list[count].stepname = s.step_name,
    reply->msg_list[count].schparmid = sp.ops_schedule_param_id,
    reply->msg_list[count].elapsed_time = datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(js
      .beg_effective_dt_tm),5), reply->msg_list[count].message = sp.message
   WITH nocounter
  ;end select
  SET reply->msg_wait_cnt = count
  SET reply->age_old_msg = cnvtint(oldmsg)
  SELECT INTO "nl:"
   FROM ops_schedule_task st,
    ops_schedule_job_step js,
    code_value cv,
    (dummyt d  WITH seq = value(mycount))
   PLAN (d)
    JOIN (cv
    WHERE cv.cdf_meaning="ERROR")
    JOIN (st
    WHERE (st.ops_schedule_control_grp_id=reply->cg_list[d.seq].scgid)
     AND st.ops_schedule_task_id > 0)
    JOIN (js
    WHERE js.ops_schedule_task_id=st.ops_schedule_task_id
     AND cv.code_value=js.status_cd)
   ORDER BY d.seq
   HEAD d.seq
    count = 0
   HEAD js.ops_schedule_job_step_id
    count = (count+ 1)
   FOOT  d.seq
    reply->cg_list[d.seq].error_cnt = count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM ops_schedule_task st,
    ops_schedule_job_step sjs,
    code_value cv,
    (dummyt d  WITH seq = value(mycount))
   PLAN (d)
    JOIN (cv
    WHERE ((cv.cdf_meaning="SKIPDEP") OR (((cv.cdf_meaning="SKIPOVER") OR (((cv.cdf_meaning="SKIPSRV"
    ) OR (cv.cdf_meaning="SKIPUSER")) )) )) )
    JOIN (st
    WHERE (st.ops_schedule_control_grp_id=reply->cg_list[d.seq].scgid)
     AND st.ops_schedule_task_id > 0)
    JOIN (sjs
    WHERE sjs.ops_schedule_task_id=st.ops_schedule_task_id
     AND sjs.status_cd=cv.code_value)
   ORDER BY d.seq
   HEAD d.seq
    count = 0
   HEAD sjs.ops_schedule_job_step_id
    count = (count+ 1)
   FOOT  d.seq
    reply->cg_list[d.seq].skip_cnt = count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM ops_schedule_task st,
    code_value cv,
    (dummyt d  WITH seq = value(mycount))
   PLAN (d)
    JOIN (cv
    WHERE ((cv.cdf_meaning="SKIPDEP") OR (((cv.cdf_meaning="SKIPOVER") OR (((cv.cdf_meaning="SKIPSRV"
    ) OR (cv.cdf_meaning="SKIPUSER")) )) )) )
    JOIN (st
    WHERE (st.ops_schedule_control_grp_id=reply->cg_list[d.seq].scgid)
     AND st.ops_schedule_task_id > 0
     AND st.status_cd=cv.code_value)
   ORDER BY d.seq
   HEAD d.seq
    count = 0
   HEAD st.ops_schedule_task_id
    count = (count+ 1)
   FOOT  d.seq
    reply->cg_list[d.seq].skip_cnt = (reply->cg_list[d.seq].skip_cnt+ count)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM ops_schedule_task st,
    code_value cv,
    (dummyt d  WITH seq = value(mycount))
   PLAN (d)
    JOIN (cv
    WHERE cv.cdf_meaning="WAITDEP")
    JOIN (st
    WHERE (st.ops_schedule_control_grp_id=reply->cg_list[d.seq].scgid)
     AND st.ops_schedule_task_id > 0
     AND st.status_cd=cv.code_value)
   ORDER BY d.seq
   HEAD d.seq
    count = 0
   HEAD st.ops_schedule_task_id
    count = (count+ 1)
   FOOT  d.seq
    reply->cg_list[d.seq].wait_dep = (reply->cg_list[d.seq].wait_dep+ count)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM ops_schedule_task st,
    ops_schedule_job_step sjs,
    ops_job_step js,
    ops_schedule_param sp,
    ops_task t,
    code_value cv,
    (dummyt d  WITH seq = value(mycount))
   PLAN (d)
    JOIN (cv
    WHERE cv.cdf_meaning="ERROR")
    JOIN (st
    WHERE (st.ops_schedule_control_grp_id=reply->cg_list[d.seq].scgid)
     AND st.ops_schedule_task_id > 0
     AND st.task_type=1)
    JOIN (sjs
    WHERE sjs.ops_schedule_task_id=st.ops_schedule_task_id
     AND cv.code_value=sjs.status_cd)
    JOIN (js
    WHERE sjs.ops_job_step_id=js.ops_job_step_id)
    JOIN (t
    WHERE st.ops_task_id=t.ops_task_id)
    JOIN (sp
    WHERE sp.ops_job_step_id=js.ops_job_step_id
     AND sp.ops_task_id=t.ops_task_id)
   ORDER BY d.seq
   HEAD d.seq
    count1 = 0
   HEAD st.ops_schedule_task_id
    count1 = (count1+ 1), count2 = 0, stat = alterlist(reply->cg_list[d.seq].job_list,count1),
    reply->cg_list[d.seq].job_list[count1].jobname = st.name, reply->cg_list[d.seq].job_list[count1].
    sjobid = st.ops_schedule_task_id, reply->cg_list[d.seq].job_list[count1].jobid = st.ops_task_id,
    reply->cg_list[d.seq].job_list[count1].parentid = 0, reply->cg_list[d.seq].job_list[count1].
    status = "ERROR", reply->cg_list[d.seq].job_list[count1].update_dttm = cnvtdatetimeutc(st
     .updt_dt_tm,2),
    reply->cg_list[d.seq].job_list[count1].sched_dttm = cnvtdatetimeutc(st.schedule_dt_tm,2), reply->
    cg_list[d.seq].job_list[count1].start_dttm = cnvtdatetimeutc(st.beg_effective_dt_tm,2), reply->
    cg_list[d.seq].job_list[count1].end_dttm = cnvtdatetimeutc(st.end_effective_dt_tm,2),
    reply->cg_list[d.seq].job_list[count1].sched_min = cnvtmin(cnvttime(st.schedule_dt_tm))
   HEAD sjs.ops_schedule_job_step_id
    count2 = (count2+ 1), stat = alterlist(reply->cg_list[d.seq].job_list[count1].step_list,count2),
    reply->cg_list[d.seq].job_list[count1].step_list[count2].step_name = js.step_name,
    reply->cg_list[d.seq].job_list[count1].step_list[count2].step_num = js.step_number, reply->
    cg_list[d.seq].job_list[count1].step_list[count2].sstep_id = sjs.ops_schedule_job_step_id, reply
    ->cg_list[d.seq].job_list[count1].step_list[count2].schparm_id = sp.ops_schedule_param_id,
    reply->cg_list[d.seq].job_list[count1].step_list[count2].sjob_id = st.ops_schedule_task_id, reply
    ->cg_list[d.seq].job_list[count1].step_list[count2].status = "ERROR", reply->cg_list[d.seq].
    job_list[count1].step_list[count2].event_data = sjs.ops_event,
    reply->cg_list[d.seq].job_list[count1].step_list[count2].update_dttm = cnvtdatetimeutc(sjs
     .updt_dt_tm,2), reply->cg_list[d.seq].job_list[count1].step_list[count2].start_dttm =
    cnvtdatetimeutc(sjs.beg_effective_dt_tm,2), reply->cg_list[d.seq].job_list[count1].step_list[
    count2].end_dttm = cnvtdatetimeutc(sjs.end_effective_dt_tm,2)
   FOOT  st.ops_schedule_task_id
    reply->cg_list[d.seq].job_list[count1].step_cnt = count2
   FOOT  d.seq
    reply->cg_list[d.seq].job_cnt = count1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM ops_schedule_task st,
    ops_schedule_task st2,
    ops_schedule_job_step sjs,
    ops_job_step js,
    ops_task t,
    ops_task t2,
    ops_schedule_param sp,
    code_value cv,
    (dummyt d  WITH seq = value(mycount))
   PLAN (d)
    JOIN (cv
    WHERE cv.cdf_meaning="ERROR")
    JOIN (st
    WHERE (st.ops_schedule_control_grp_id=reply->cg_list[d.seq].scgid)
     AND st.ops_schedule_task_id > 0
     AND st.task_type=0)
    JOIN (st2
    WHERE st2.parent_id=st.ops_schedule_task_id
     AND st2.ops_schedule_task_id > 0
     AND st2.task_type=2)
    JOIN (sjs
    WHERE sjs.ops_schedule_task_id=st2.ops_schedule_task_id
     AND cv.code_value=sjs.status_cd)
    JOIN (js
    WHERE js.ops_job_step_id=sjs.ops_job_step_id)
    JOIN (t
    WHERE t.ops_task_id=st.ops_task_id)
    JOIN (t2
    WHERE t2.ops_task_id=st2.ops_task_id)
    JOIN (sp
    WHERE sp.ops_task_id=t2.ops_task_id
     AND sp.ops_job_step_id=js.ops_job_step_id)
   ORDER BY d.seq
   HEAD d.seq
    count = 0
   HEAD st.ops_schedule_task_id
    count = (count+ 1), count1 = 0, stat = alterlist(reply->cg_list[d.seq].jgrp_list,count),
    reply->cg_list[d.seq].jgrp_list[count].jgname = st.name, reply->cg_list[d.seq].jgrp_list[count].
    sjgid = st.ops_schedule_task_id, reply->cg_list[d.seq].jgrp_list[count].jgid = st.ops_task_id,
    reply->cg_list[d.seq].jgrp_list[count].status = "ERROR", reply->cg_list[d.seq].jgrp_list[count].
    update_dttm = cnvtdatetimeutc(st.updt_dt_tm,2), reply->cg_list[d.seq].jgrp_list[count].sched_dttm
     = cnvtdatetimeutc(st.schedule_dt_tm,2),
    reply->cg_list[d.seq].jgrp_list[count].start_dttm = cnvtdatetimeutc(st.beg_effective_dt_tm,2),
    reply->cg_list[d.seq].jgrp_list[count].end_dttm = cnvtdatetimeutc(st.end_effective_dt_tm,2),
    reply->cg_list[d.seq].jgrp_list[count].sched_min = cnvtmin(cnvttime(st.schedule_dt_tm))
   HEAD st2.ops_schedule_task_id
    count1 = (count1+ 1), count2 = 0, stat = alterlist(reply->cg_list[d.seq].jgrp_list[count].
     job_list,count1),
    reply->cg_list[d.seq].jgrp_list[count].job_list[count1].jobname = st2.name, reply->cg_list[d.seq]
    .jgrp_list[count].job_list[count1].sjobid = st2.ops_schedule_task_id, reply->cg_list[d.seq].
    jgrp_list[count].job_list[count1].jobid = st2.ops_task_id,
    reply->cg_list[d.seq].jgrp_list[count].job_list[count1].parentid = st2.parent_id, reply->cg_list[
    d.seq].jgrp_list[count].job_list[count1].status = "ERROR", reply->cg_list[d.seq].jgrp_list[count]
    .job_list[count1].update_dttm = cnvtdatetimeutc(st2.updt_dt_tm,2),
    reply->cg_list[d.seq].jgrp_list[count].job_list[count1].sched_dttm = cnvtdatetimeutc(st2
     .schedule_dt_tm,2), reply->cg_list[d.seq].jgrp_list[count].job_list[count1].start_dttm =
    cnvtdatetimeutc(st2.beg_effective_dt_tm,2), reply->cg_list[d.seq].jgrp_list[count].job_list[
    count1].end_dttm = cnvtdatetimeutc(st2.end_effective_dt_tm,2),
    reply->cg_list[d.seq].jgrp_list[count].job_list[count1].sched_min = cnvtmin(cnvttime(st2
      .schedule_dt_tm)), reply->cg_list[d.seq].jgrp_list[count].job_list[count1].time_ind = t2
    .time_ind
   HEAD sjs.ops_schedule_job_step_id
    count2 = (count2+ 1), stat = alterlist(reply->cg_list[d.seq].jgrp_list[count].job_list[count1].
     step_list,count2), reply->cg_list[d.seq].jgrp_list[count].job_list[count1].step_list[count2].
    step_name = js.step_name,
    reply->cg_list[d.seq].jgrp_list[count].job_list[count1].step_list[count2].step_num = js
    .step_number, reply->cg_list[d.seq].jgrp_list[count].job_list[count1].step_list[count2].sstep_id
     = sjs.ops_schedule_job_step_id, reply->cg_list[d.seq].jgrp_list[count].job_list[count1].
    step_list[count2].schparm_id = sp.ops_schedule_param_id,
    reply->cg_list[d.seq].jgrp_list[count].job_list[count1].step_list[count2].sjob_id = st2
    .ops_schedule_task_id, reply->cg_list[d.seq].jgrp_list[count].job_list[count1].step_list[count2].
    status = "ERROR", reply->cg_list[d.seq].jgrp_list[count].job_list[count1].step_list[count2].
    update_dttm = cnvtdatetimeutc(sjs.updt_dt_tm,2),
    reply->cg_list[d.seq].jgrp_list[count].job_list[count1].step_list[count2].event_data = sjs
    .ops_event, reply->cg_list[d.seq].jgrp_list[count].job_list[count1].step_list[count2].start_dttm
     = cnvtdatetimeutc(sjs.beg_effective_dt_tm,2), reply->cg_list[d.seq].jgrp_list[count].job_list[
    count1].step_list[count2].end_dttm = cnvtdatetimeutc(sjs.end_effective_dt_tm,2)
   FOOT  st2.ops_schedule_task_id
    reply->cg_list[d.seq].jgrp_list[count].job_list[count1].step_cnt = count2
   FOOT  st.ops_schedule_task_id
    reply->cg_list[d.seq].jgrp_list[count].job_cnt = count1
   FOOT  d.seq
    reply->cg_list[d.seq].jgrp_cnt = count
   WITH nocounter
  ;end select
  SET xcount = 0
  SELECT INTO "nl:"
   FROM ops_schedule_task st,
    ops_task t,
    ops_schedule_job_step js,
    ops_job_step s,
    ops_schedule_param sp,
    code_value cv,
    (dummyt d  WITH seq = value(mycount))
   PLAN (d)
    JOIN (cv
    WHERE ((cv.cdf_meaning="COMPLETE") OR (cv.cdf_meaning="INPROCESS")) )
    JOIN (st
    WHERE (st.ops_schedule_control_grp_id=reply->cg_list[d.seq].scgid))
    JOIN (t
    WHERE t.ops_task_id=st.ops_task_id)
    JOIN (js
    WHERE js.ops_schedule_task_id=st.ops_schedule_task_id
     AND js.status_cd=cv.code_value
     AND js.avg_flag=3)
    JOIN (s
    WHERE s.ops_job_step_id=js.ops_job_step_id)
    JOIN (sp
    WHERE sp.ops_job_step_id=js.ops_job_step_id
     AND sp.ops_task_id=t.ops_task_id)
   ORDER BY d.seq
   HEAD d.seq
    xcount = 0
   HEAD js.ops_schedule_job_step_id
    IF (cv.cdf_meaning="COMPLETE")
     IF (((js.end_effective_dt_tm - js.beg_effective_dt_tm) > (js.thresh_dt_tm - st.schedule_dt_tm)))
      xcount = (xcount+ 1), stat = alterlist(reply->cg_list[d.seq].thresh_list,xcount), reply->
      cg_list[d.seq].thresh_list[xcount].thresh_type = 3,
      reply->cg_list[d.seq].thresh_list[xcount].jobid = t.ops_task_id, reply->cg_list[d.seq].
      thresh_list[xcount].jobname = st.name, reply->cg_list[d.seq].thresh_list[xcount].schparmid = sp
      .ops_schedule_param_id,
      reply->cg_list[d.seq].thresh_list[xcount].stepname = s.step_name, reply->cg_list[d.seq].
      thresh_list[xcount].percent = sp.thresh_percent, reply->cg_list[d.seq].thresh_list[xcount].
      elapsed_time = datetimediff(cnvtdatetime(js.end_effective_dt_tm),cnvtdatetime(js
        .beg_effective_dt_tm),5)
     ENDIF
    ELSEIF (cv.cdf_meaning="INPROCESS")
     IF (((cnvtdatetime(curdate,curtime3) - js.beg_effective_dt_tm) > (js.thresh_dt_tm - st
     .schedule_dt_tm)))
      xcount = (xcount+ 1), stat = alterlist(reply->cg_list[d.seq].thresh_list,xcount), reply->
      cg_list[d.seq].thresh_list[xcount].thresh_type = 3,
      reply->cg_list[d.seq].thresh_list[xcount].jobid = t.ops_task_id, reply->cg_list[d.seq].
      thresh_list[xcount].jobname = st.name, reply->cg_list[d.seq].thresh_list[xcount].schparmid = sp
      .ops_schedule_param_id,
      reply->cg_list[d.seq].thresh_list[xcount].stepname = s.step_name, reply->cg_list[d.seq].
      thresh_list[xcount].percent = sp.thresh_percent, reply->cg_list[d.seq].thresh_list[xcount].
      elapsed_time = datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(js.beg_effective_dt_tm),
       5)
     ENDIF
    ENDIF
    reply->cg_list[d.seq].thr_exceed = xcount
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM ops_schedule_task st,
    ops_task t,
    code_value cv,
    (dummyt d  WITH seq = value(mycount))
   PLAN (d)
    JOIN (cv
    WHERE ((cv.cdf_meaning="COMPLETE") OR (cv.cdf_meaning="INPROCESS")) )
    JOIN (st
    WHERE (st.ops_schedule_control_grp_id=reply->cg_list[d.seq].scgid)
     AND st.status_cd=cv.code_value
     AND st.avg_flag=3)
    JOIN (t
    WHERE st.ops_task_id=t.ops_task_id
     AND t.thresh_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    xcount = reply->cg_list[d.seq].thr_exceed
   HEAD t.ops_task_id
    IF (cv.cdf_meaning="COMPLETE"
     AND st.avg_flag=3)
     IF (((st.end_effective_dt_tm - st.beg_effective_dt_tm) > (st.thresh_dt_tm - st.schedule_dt_tm)))
      xcount = (xcount+ 1), stat = alterlist(reply->cg_list[d.seq].thresh_list,xcount), reply->
      cg_list[d.seq].thresh_list[xcount].thresh_type = st.task_type,
      reply->cg_list[d.seq].thresh_list[xcount].jobid = t.ops_task_id, reply->cg_list[d.seq].
      thresh_list[xcount].jobname = st.name, reply->cg_list[d.seq].thresh_list[xcount].schparmid = 0,
      reply->cg_list[d.seq].thresh_list[xcount].stepname = "N/A", reply->cg_list[d.seq].thresh_list[
      xcount].percent = t.thresh_percent, reply->cg_list[d.seq].thresh_list[xcount].elapsed_time =
      datetimediff(cnvtdatetime(st.end_effective_dt_tm),cnvtdatetime(st.beg_effective_dt_tm),5)
     ENDIF
    ELSEIF (cv.cdf_meaning="INPROCESS"
     AND st.avg_flag=3)
     IF (((cnvtdatetime(curdate,curtime3) - st.beg_effective_dt_tm) > (st.thresh_dt_tm - st
     .schedule_dt_tm)))
      xcount = (xcount+ 1), stat = alterlist(reply->cg_list[d.seq].thresh_list,xcount), reply->
      cg_list[d.seq].thresh_list[xcount].thresh_type = st.task_type,
      reply->cg_list[d.seq].thresh_list[xcount].jobid = t.ops_task_id, reply->cg_list[d.seq].
      thresh_list[xcount].jobname = st.name, reply->cg_list[d.seq].thresh_list[xcount].schparmid = 0,
      reply->cg_list[d.seq].thresh_list[xcount].stepname = "N/A", reply->cg_list[d.seq].thresh_list[
      xcount].percent = t.thresh_percent, reply->cg_list[d.seq].thresh_list[xcount].elapsed_time =
      datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(st.beg_effective_dt_tm),5)
     ENDIF
    ENDIF
   FOOT  d.seq
    reply->cg_list[d.seq].thr_exceed = xcount
   WITH nocounter
  ;end select
 ENDIF
 SET error_code = error(errmsg,0)
 IF (error_code=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
