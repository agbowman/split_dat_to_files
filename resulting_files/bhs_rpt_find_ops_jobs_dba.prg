CREATE PROGRAM bhs_rpt_find_ops_jobs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  'Enter Batch Selection String (no "*")' = ""
  WITH outdev, script_name
 SET script_name_find = concat(patstring("*"),cnvtupper(trim( $SCRIPT_NAME,3)),patstring("*"))
 CALL echo(build("script_name_find =",script_name_find))
 SELECT INTO  $OUTDEV
  o.host, o.name, ot.job_grp_name,
  oj.name, batch_job = trim(substring(1,130,osp.batch_selection)), o.end_effective_dt_tm,
  osp_active_status_disp = uar_get_code_display(osp.active_status_cd), osp.active_status_prsnl_id,
  control_enabled = o.enable_ind,
  task_autostart = ot.autostart_ind, ot.enable_ind, ot.active_ind
  FROM ops_schedule_param osp,
   ops_task ot,
   ops_control_group o,
   ops_job oj
  PLAN (osp
   WHERE osp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND cnvtupper(osp.batch_selection)=patstring(script_name_find))
   JOIN (ot
   WHERE ot.ops_task_id=osp.ops_task_id)
   JOIN (oj
   WHERE ot.ops_job_id=oj.ops_job_id)
   JOIN (o
   WHERE o.ops_control_grp_id=ot.ops_control_grp_id)
  WITH maxrec = 5000, nocounter, separator = " ",
   format
 ;end select
END GO
