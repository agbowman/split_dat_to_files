CREATE PROGRAM bhs_rpt_ops_steps
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $1
  name = oj.name, step = o.step_name, event = replace(os.ops_event,char(13)," ",1),
  begin = os.beg_effective_dt_tm"@SHORTDATETIME", endtime = os.end_effective_dt_tm"@SHORTDATETIME",
  duration = format(datetimediff(os.end_effective_dt_tm,os.beg_effective_dt_tm),"HH:MM:SS;;Z")
  FROM ops_job oj,
   ops_job_step o,
   ops_schedule_job_step os,
   ops_schedule_task ost
  PLAN (oj
   WHERE oj.active_ind=1)
   JOIN (o
   WHERE o.ops_job_id=oj.ops_job_id)
   JOIN (os
   WHERE os.ops_job_step_id=o.ops_job_step_id
    AND os.active_ind=1
    AND os.beg_effective_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
    235959))
   JOIN (ost
   WHERE ost.ops_schedule_task_id=os.ops_schedule_task_id)
  ORDER BY duration DESC, 0
  WITH nocounter, separator = " ", format
 ;end select
END GO
