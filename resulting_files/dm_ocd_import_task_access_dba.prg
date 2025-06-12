CREATE PROGRAM dm_ocd_import_task_access:dba
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
  a.position_cd
  FROM application_group a
  WHERE a.position_cd=position_cd
   AND a.app_group_cd=def_appgrp_cd
 ;end select
 IF (curqual=0)
  INSERT  FROM application_group a
   SET a.application_group_id = cnvtint(seq(cpm_seq,nextval)), a.position_cd = position_cd, a
    .app_group_cd = def_appgrp_cd,
    a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime(
     "01-JAN-2099"), a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    a.updt_id = 0, a.updt_task = reqinfo->updt_task, a.updt_applctx = 0,
    a.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 FREE RECORD tasks
 RECORD tasks(
   1 count = i4
   1 qual[*]
     2 number = i4
     2 exist = i2
 )
 SET stat = alterlist(tasks->qual,0)
 SET tasks->count = 0
 SELECT INTO "nl:"
  t.task_number
  FROM application_task t
  WHERE  NOT ( EXISTS (
  (SELECT
   null
   FROM dm_info di
   WHERE cnvtint(di.info_name)=t.task_number
    AND di.info_domain="DM2_DBA_TASK_EXCL"
    AND di.info_number=1)))
  DETAIL
   tasks->count = (tasks->count+ 1), stat = alterlist(tasks->qual,tasks->count), tasks->qual[tasks->
   count].number = t.task_number,
   tasks->qual[tasks->count].exist = 0
  WITH nocounter
 ;end select
 IF ((tasks->count > 0))
  SELECT INTO "nl:"
   ta.task_number
   FROM task_access ta,
    (dummyt d  WITH seq = value(tasks->count))
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_number=tasks->qual[d.seq].number)
     AND ta.app_group_cd=def_appgrp_cd)
   DETAIL
    tasks->qual[d.seq].exist = 1
   WITH nocounter
  ;end select
  INSERT  FROM task_access ta,
    (dummyt d  WITH seq = value(tasks->count))
   SET ta.seq = 1, ta.task_number = tasks->qual[d.seq].number, ta.app_group_cd = def_appgrp_cd,
    ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta.updt_id = 0, ta.updt_task = reqinfo->updt_task,
    ta.updt_applctx = 0, ta.updt_cnt = 0
   PLAN (d
    WHERE (tasks->qual[d.seq].exist=0))
    JOIN (ta)
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
#exit_script
END GO
