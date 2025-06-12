CREATE PROGRAM dm_atr_check_misc:dba
 SET app_group_err = fillstring(20," ")
 SET app_group_ind = 0
 SET task_acc_err = fillstring(20," ")
 SET task_acc_ind = 0
 SET sys_account_err = fillstring(20," ")
 SET sys_account_ind = 0
 SET count1 = 0
 SET def_appgrp_cd = 0
 SET position_cd = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=500
   AND c.display_key="DBA"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   def_appgrp_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=88
   AND c.display_key="DBA"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   position_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.application_group_id
  FROM application_group a
  WHERE a.position_cd=position_cd
   AND a.app_group_cd=def_appgrp_cd
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("app_group_cd successful!")
  SET app_group_err = "app_group_cd:success"
  SET app_group_ind = 1
 ELSE
  CALL echo("app_group_cd failed!")
  SET app_group_err = "app_group_cd:failure"
  SET app_group_ind = 0
 ENDIF
 FREE RECORD tasks
 RECORD tasks(
   1 count = i4
   1 ta_count = i4
   1 qual[*]
     2 number = i4
 )
 SET stat = alterlist(tasks->qual,0)
 SET tasks->count = 0
 SET tasks->ta_count = 0
 SELECT INTO "nl:"
  t.task_number
  FROM application_task t
  DETAIL
   tasks->count = (tasks->count+ 1), stat = alterlist(tasks->qual,tasks->count), tasks->qual[tasks->
   count].number = t.task_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ta.task_number
  FROM task_access ta,
   (dummyt d  WITH seq = value(tasks->count))
  PLAN (d)
   JOIN (ta
   WHERE (ta.task_number=tasks->qual[d.seq].number)
    AND ta.app_group_cd=def_appgrp_cd)
  DETAIL
   tasks->ta_count = (tasks->ta_count+ 1)
  WITH nocounter
 ;end select
 IF ((tasks->count=tasks->ta_count))
  CALL echo("task_access successful!")
  SET task_acc_err = "task_access:success"
  SET task_acc_ind = 1
 ELSE
  CALL echo("task_access failed!")
  SET task_acc_err = "task_access:failure"
  SET task_acc_ind = 0
 ENDIF
 SELECT INTO "nl:"
  p.person_id
  FROM person p,
   prsnl pr
  WHERE pr.username IN ("SYSTEM", "CERNER", "SYSTEMOE")
   AND p.person_id=pr.person_id
  WITH nocounter
 ;end select
 IF (curqual >= 3)
  CALL echo("system accounts successful!")
  SET sys_account_err = "sys_accounts:success"
  SET sys_account_ind = 1
 ELSE
  CALL echo("system accounts failed!")
  SET sys_account_err = "sys_accounts:failure"
  SET sys_account_ind = 0
 ENDIF
 SET error_msg = concat(trim(app_group_err)," ; ",trim(sys_account_err)," ; ",trim(task_acc_err))
 SET request->setup_proc[1].error_msg = error_msg
 IF (app_group_ind=1
  AND sys_account_ind=1
  AND task_acc_ind=1)
  SET request->setup_proc[1].success_ind = 1
 ELSE
  SET request->setup_proc[1].success_ind = 0
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
