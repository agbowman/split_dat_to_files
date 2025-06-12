CREATE PROGRAM bhs_wh_ops_monitor_det:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET file = "bhs_wh_ops_mon.dat"
 SELECT INTO value(file)
  name = substring(1,33,oj.name), event = substring(1,100,replace(os.ops_event,char(13)," ",1)),
  begintime = os.beg_effective_dt_tm"@SHORTDATETIME",
  endtime = os.end_effective_dt_tm"@SHORTDATETIME", duration = format(datetimediff(os
    .end_effective_dt_tm,os.beg_effective_dt_tm),"HH:MM:SS;;Z"), dursecs = datetimediff(os
   .end_effective_dt_tm,os.beg_effective_dt_tm,5)
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
  ORDER BY duration DESC
  HEAD REPORT
   col 5, "JOB NAME", col 45,
   "EVENT", col 160, "START DATE/TIME",
   col 185, "END DATE/TIME", col 210,
   "DURATION", row + 2
  DETAIL
   IF (dursecs >= 300)
    col 5, name, event1 = substring(1,100,replace(event,char(10)," ",1)),
    event2 = substring(1,100,replace(event1,char(9)," ",1)), col 45, event1,
    col 160, begintime, col 185,
    endtime, col 210, duration,
    row + 1
   ENDIF
  WITH nocounter, maxcol = 300, maxrow = 1000
 ;end select
 EXECUTE bhs_ma_email_file
 CALL emailfile(file,"bhs_wh_ops_mon.txt","ciscore@bhs.org","Operations Job Monitor",1)
END GO
