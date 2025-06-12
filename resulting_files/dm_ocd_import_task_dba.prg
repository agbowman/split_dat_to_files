CREATE PROGRAM dm_ocd_import_task:dba
 FREE SET status
 RECORD status(
   1 qual[*]
     2 exist = i2
     2 task_access_exist = i2
     2 subordinate_task_ind = i2
 )
 SET stat = alterlist(status->qual,atr->atr_count)
 CALL echo("Importing Tasks into clinical tables...")
 SELECT INTO "nl:"
  t.task_number
  FROM application_task t,
   (dummyt d  WITH seq = value(atr->atr_count))
  PLAN (d)
   JOIN (t
   WHERE (t.task_number=atr->atr_list[d.seq].task_number))
  DETAIL
   status->qual[d.seq].exist = 1
   IF (t.subordinate_task_ind=0
    AND (atr->atr_list[d.seq].subordinate_task_ind=1))
    status->qual[d.seq].subordinate_task_ind = t.subordinate_task_ind
   ELSE
    status->qual[d.seq].subordinate_task_ind = atr->atr_list[d.seq].subordinate_task_ind
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("  Updating existing Tasks into clinical tables...")
 UPDATE  FROM application_task t,
   (dummyt d  WITH seq = value(atr->atr_count))
  SET t.seq = 1, t.description = atr->atr_list[d.seq].description, t.optional_required_flag = atr->
   atr_list[d.seq].optional_required_flag,
   t.subordinate_task_ind = status->qual[d.seq].subordinate_task_ind, t.text = atr->atr_list[d.seq].
   text, t.old_task_number = atr->atr_list[d.seq].old_task_number,
   t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task = reqinfo->updt_task, t.updt_id = 0.0,
   t.updt_applctx = 0, t.updt_cnt = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=1)
    AND (atr->atr_list[d.seq].deleted_ind != 1))
   JOIN (t
   WHERE (t.task_number=atr->atr_list[d.seq].task_number))
  WITH nocounter
 ;end update
 CALL echo("  Inserting new Tasks into clinical tables...")
 INSERT  FROM application_task t,
   (dummyt d  WITH seq = value(atr->atr_count))
  SET t.seq = 1, t.task_number = atr->atr_list[d.seq].task_number, t.description = atr->atr_list[d
   .seq].description,
   t.active_dt_tm = cnvtdatetime(curdate,curtime3), t.active_ind = atr->atr_list[d.seq].active_ind, t
   .inactive_dt_tm =
   IF ((atr->atr_list[d.seq].inactive_dt_tm > 0)) cnvtdatetime(atr->atr_list[d.seq].inactive_dt_tm)
   ELSE null
   ENDIF
   ,
   t.optional_required_flag = atr->atr_list[d.seq].optional_required_flag, t.subordinate_task_ind =
   atr->atr_list[d.seq].subordinate_task_ind, t.text = atr->atr_list[d.seq].text,
   t.old_task_number = atr->atr_list[d.seq].old_task_number, t.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), t.updt_task = reqinfo->updt_task,
   t.updt_id = 0.0, t.updt_applctx = 0, t.updt_cnt = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=0)
    AND (atr->atr_list[d.seq].deleted_ind != 1))
   JOIN (t)
  WITH nocounter
 ;end insert
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   t.table_name
   FROM user_tables t
   WHERE t.table_name="OCD_INSTALL_LOG"
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual
  AND validate(ocd_number,0))
  FOR (it_i = 1 TO atr->atr_count)
    IF ( NOT (status->qual[it_i].exist))
     DELETE  FROM ocd_install_log l
      WHERE l.component_type="TASK"
       AND l.end_state=trim(cnvtstring(atr->atr_list[it_i].task_number),3)
      WITH nocounter
     ;end delete
     SET atr_log_id = 0.0
     SELECT INTO "nl:"
      y = seq(dm_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       atr_log_id = y
      WITH nocounter
     ;end select
     INSERT  FROM ocd_install_log l
      SET l.log_id = atr_log_id, l.install_dt_tm = cnvtdatetime(curdate,curtime3), l.ocd = ocd_number,
       l.component_type = "TASK", l.end_state = trim(cnvtstring(atr->atr_list[it_i].task_number),3),
       l.update_ind = 0
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ENDIF
 CALL echo("Checking for new tasks in task access...")
 SELECT INTO "nl:"
  t.task_number
  FROM task_access t,
   (dummyt d  WITH seq = value(atr->atr_count))
  PLAN (d
   WHERE (status->qual[d.seq].exist=0))
   JOIN (t
   WHERE (t.task_number=atr->atr_list[d.seq].task_number))
  DETAIL
   status->qual[d.seq].task_access_exist = 1
  WITH nocounter
 ;end select
 CALL echo("Copy task_access info for new tasks from old_task_number...")
 FOR (it_i = 1 TO atr->atr_count)
   IF ((status->qual[it_i].exist=0)
    AND (status->qual[it_i].task_access_exist=0)
    AND (atr->atr_list[it_i].old_task_number > 0))
    FREE RECORD task_ag
    RECORD task_ag(
      1 cnt = i4
      1 ag[*]
        2 app_group_cd = f8
    )
    SELECT INTO "nl:"
     FROM task_access t
     WHERE (t.task_number=atr->atr_list[it_i].old_task_number)
     DETAIL
      task_ag->cnt = (task_ag->cnt+ 1), stat = alterlist(task_ag->ag,task_ag->cnt), task_ag->ag[
      task_ag->cnt].app_group_cd = t.app_group_cd
     WITH nocounter
    ;end select
    IF ((task_ag->cnt > 0))
     INSERT  FROM task_access ta,
       (dummyt d  WITH seq = value(task_ag->cnt))
      SET ta.seq = 1, ta.task_number = atr->atr_list[it_i].task_number, ta.app_group_cd = task_ag->
       ag[d.seq].app_group_cd,
       ta.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ta)
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
 ENDFOR
 COMMIT
END GO
