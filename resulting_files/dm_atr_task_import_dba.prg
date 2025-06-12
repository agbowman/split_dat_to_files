CREATE PROGRAM dm_atr_task_import:dba
 FREE SET status
 RECORD status(
   1 qual[*]
     2 exist = i1
     2 task_access_exist = i2
 )
 SET stat = alterlist(status->qual,request->atr_count)
 CALL echo("Importing Tasks into clinical tables...")
 SELECT INTO "nl:"
  t.task_number
  FROM application_task t,
   (dummyt d  WITH seq = value(request->atr_count))
  PLAN (d)
   JOIN (t
   WHERE (t.task_number=request->atr_list[d.seq].task_number))
  DETAIL
   status->qual[d.seq].exist = 1
  WITH nocounter
 ;end select
 CALL echo("  Updating existing Tasks into clinical tables...")
 UPDATE  FROM application_task t,
   (dummyt d  WITH seq = value(request->atr_count))
  SET t.seq = 1, t.description = request->atr_list[d.seq].description, t.active_dt_tm = cnvtdatetime(
    curdate,curtime3),
   t.active_ind = request->atr_list[d.seq].active_ind, t.inactive_dt_tm =
   IF ((request->atr_list[d.seq].inactive_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     inactive_dt_tm)
   ELSE null
   ENDIF
   , t.optional_required_flag = request->atr_list[d.seq].optional_required_flag,
   t.subordinate_task_ind = request->atr_list[d.seq].subordinate_task_ind, t.text = request->
   atr_list[d.seq].text, t.old_task_number = request->atr_list[d.seq].old_task_number,
   t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task = 0, t.updt_id = 0.0,
   t.updt_applctx = 0, t.updt_cnt = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=1)
    AND (request->atr_list[d.seq].deleted_ind != 1))
   JOIN (t
   WHERE (t.task_number=request->atr_list[d.seq].task_number))
  WITH nocounter
 ;end update
 CALL echo("  Inserting new Tasks into clinical tables...")
 INSERT  FROM application_task t,
   (dummyt d  WITH seq = value(request->atr_count))
  SET t.seq = 1, t.task_number = request->atr_list[d.seq].task_number, t.description = request->
   atr_list[d.seq].description,
   t.active_dt_tm = cnvtdatetime(curdate,curtime3), t.active_ind = request->atr_list[d.seq].
   active_ind, t.inactive_dt_tm =
   IF ((request->atr_list[d.seq].inactive_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     inactive_dt_tm)
   ELSE null
   ENDIF
   ,
   t.optional_required_flag = request->atr_list[d.seq].optional_required_flag, t.subordinate_task_ind
    = request->atr_list[d.seq].subordinate_task_ind, t.text = request->atr_list[d.seq].text,
   t.old_task_number = request->atr_list[d.seq].old_task_number, t.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), t.updt_task = 0,
   t.updt_id = 0.0, t.updt_applctx = 0, t.updt_cnt = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=0)
    AND (request->atr_list[d.seq].deleted_ind != 1))
   JOIN (t)
  WITH nocounter
 ;end insert
 CALL echo("  Deleting unwanted Tasks from clinical tables...")
 DELETE  FROM application_task t,
   (dummyt d  WITH seq = value(request->atr_count))
  SET t.seq = 1
  PLAN (d
   WHERE (request->atr_list[d.seq].deleted_ind=1)
    AND (status->qual[d.seq].exist=1))
   JOIN (t
   WHERE (t.task_number=request->atr_list[d.seq].task_number))
  WITH nocounter
 ;end delete
 CALL echo("Checking for new tasks in task access...")
 SELECT INTO "nl:"
  t.task_number
  FROM task_access t,
   (dummyt d  WITH seq = value(request->atr_count))
  PLAN (d
   WHERE (status->qual[d.seq].exist=0)
    AND (request->atr_list[d.seq].deleted_ind != 1))
   JOIN (t
   WHERE (t.task_number=request->atr_list[d.seq].task_number))
  DETAIL
   status->qual[d.seq].task_access_exist = 1
  WITH nocounter
 ;end select
 CALL echo("Copy task_access info for new tasks from old_task_number...")
 FOR (it_i = 1 TO request->atr_count)
   IF ((status->qual[it_i].exist=0)
    AND (request->atr_list[it_i].deleted_ind != 1)
    AND (status->qual[it_i].task_access_exist=0)
    AND (request->atr_list[it_i].old_task_number > 0))
    FREE RECORD task_ag
    RECORD task_ag(
      1 cnt = i4
      1 ag[*]
        2 app_group_cd = f8
    )
    SELECT INTO "nl:"
     FROM task_access t
     WHERE (t.task_number=request->atr_list[it_i].old_task_number)
     DETAIL
      task_ag->cnt = (task_ag->cnt+ 1), stat = alterlist(task_ag->ag,task_ag->cnt), task_ag->ag[
      task_ag->cnt].app_group_cd = t.app_group_cd
     WITH nocounter
    ;end select
    IF ((task_ag->cnt > 0))
     INSERT  FROM task_access ta,
       (dummyt d  WITH seq = value(task_ag->cnt))
      SET ta.seq = 1, ta.task_number = request->atr_list[it_i].task_number, ta.app_group_cd = task_ag
       ->ag[d.seq].app_group_cd,
       ta.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ta)
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
 ENDFOR
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
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM application_group a
   SET a.application_group_id = cnvtint(seq(cpm_seq,nextval)), a.position_cd = position_cd, a
    .app_group_cd = def_appgrp_cd,
    a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime(
     "01-JAN-2099"), a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    a.updt_id = 0, a.updt_task = 0, a.updt_applctx = 0,
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
 SET stat = alterlist(tasks->qual,request->atr_count)
 SELECT INTO "nl:"
  ta.task_number
  FROM task_access ta,
   (dummyt d  WITH seq = value(request->atr_count))
  PLAN (d)
   JOIN (ta
   WHERE (ta.task_number=request->atr_list[d.seq].task_number)
    AND ta.app_group_cd=def_appgrp_cd)
  DETAIL
   tasks->qual[d.seq].exist = 1
  WITH nocounter
 ;end select
 CALL echo("  Inserting new Tasks_Access rows...")
 INSERT  FROM task_access ta,
   (dummyt d  WITH seq = value(request->atr_count))
  SET ta.seq = 1, ta.task_number = request->atr_list[d.seq].task_number, ta.app_group_cd =
   def_appgrp_cd,
   ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta.updt_id = 0, ta.updt_task = 0,
   ta.updt_applctx = 0, ta.updt_cnt = 0
  PLAN (d
   WHERE (tasks->qual[d.seq].exist=0)
    AND (request->atr_list[d.seq].deleted_ind != 1))
   JOIN (ta)
  WITH nocounter
 ;end insert
 CALL echo("  Deleting un-wanted Task_Access rows...")
 DELETE  FROM task_access ta,
   (dummyt d  WITH seq = value(request->atr_count))
  SET ta.seq = 1
  PLAN (d
   WHERE (request->atr_list[d.seq].deleted_ind=1)
    AND (tasks->qual[d.seq].exist=1))
   JOIN (ta
   WHERE (ta.task_number=request->atr_list[d.seq].task_number))
  WITH nocounter
 ;end delete
 COMMIT
END GO
