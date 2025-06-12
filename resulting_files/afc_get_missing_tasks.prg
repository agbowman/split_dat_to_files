CREATE PROGRAM afc_get_missing_tasks
 SET afc_get_missing_tasks_version = "44398.FT.003"
 DECLARE 79_complete = f8
 DECLARE 79_dropped = f8
 DECLARE 14024_dcp_chart = f8
 DECLARE 14024_dcp_done = f8
 DECLARE 14024_dcp_notdone = f8
 DECLARE ntaskactivitycnt = i2 WITH public, noconstant(0)
 SET code_set = 79
 SET cdf_meaning = "COMPLETE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,79_complete)
 IF (79_complete IN (0.0, null))
  CALL echo("79_COMPLETE of codeset 79 IS NULL")
  GO TO end_program
 ENDIF
 SET code_set = 14024
 SET cdf_meaning = "DCP_CHART"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,14024_dcp_chart)
 IF (14024_dcp_chart IN (0.0, null))
  CALL echo("14024_DCP_CHART of codeset 14024 IS NULL")
  GO TO end_program
 ENDIF
 SET cdf_meaning = "DCP_DONE"
 SET code_set = 14024
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,14024_dcp_done)
 IF (14024_dcp_done IN (0.0, null))
  CALL echo("14024_DCP_DONE of codeset 14024 IS NULL")
  GO TO end_program
 ENDIF
 SET cdf_meaning = "DCP_NOTDONE"
 SET code_set = 14024
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,14024_dcp_notdone)
 IF (14024_dcp_notdone IN (0.0, null))
  CALL echo("14024_DCP_NOTDONE of codeset 14024 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(79,"DROPPED",1,79_dropped)
 IF (79_dropped IN (0.0, null))
  CALL echo("79_DROPPED of codeset 79 IS NULL")
  GO TO end_program
 ENDIF
 SET ntaskactioncnt = 0
 SELECT INTO "nl:"
  ta.task_id, ta.person_id, ta.order_id,
  ta.location_cd, ta.encntr_id, ta.reference_task_id,
  ta.task_status_cd, ta.task_status_reason_cd, ta.catalog_cd,
  ta.updt_dt_tm, ta.updt_id, ot.task_description
  FROM task_activity ta,
   order_task ot
  PLAN (ta
   WHERE ta.updt_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate)
    AND ta.task_status_cd=79_complete
    AND ta.task_status_reason_cd IN (14024_dcp_chart, 14024_dcp_done, 14024_dcp_notdone))
   JOIN (ot
   WHERE ot.reference_task_id=ta.reference_task_id)
  ORDER BY ta.task_id
  HEAD ta.task_id
   ntaskactivitycnt = (ntaskactivitycnt+ 1)
   IF (ntaskactivitycnt > size(tasks->tasks,5))
    stat = alterlist(tasks->tasks,(ntaskactivitycnt+ 10))
   ENDIF
   tasks->tasks[ntaskactivitycnt].cs_order_id = ta.order_id, tasks->tasks[ntaskactivitycnt].
   cs_catalog_cd = ta.catalog_cd, tasks->tasks[ntaskactivitycnt].order_id = ta.order_id,
   tasks->tasks[ntaskactivitycnt].catalog_cd = ta.catalog_cd, tasks->tasks[ntaskactivitycnt].task_id
    = ta.task_id, tasks->tasks[ntaskactivitycnt].reference_task_id = ta.reference_task_id,
   tasks->tasks[ntaskactivitycnt].person_id = ta.person_id, tasks->tasks[ntaskactivitycnt].encntr_id
    = ta.encntr_id, tasks->tasks[ntaskactivitycnt].task_status_cd = ta.task_status_cd,
   tasks->tasks[ntaskactivitycnt].task_status_reason_cd = ta.task_status_reason_cd, tasks->tasks[
   ntaskactivitycnt].task_dt_tm = ta.updt_dt_tm, tasks->tasks[ntaskactivitycnt].location_cd = ta
   .location_cd,
   tasks->tasks[ntaskactivitycnt].updt_id = ta.updt_id
   IF (ta.task_status_cd=79_complete
    AND ta.task_status_reason_cd IN (14024_dcp_done, 14024_dcp_chart))
    tasks->tasks[ntaskactivitycnt].complete_ind = 1
   ELSEIF (ta.task_status_cd=79_complete
    AND ta.task_status_reason_cd=14024_dcp_notdone)
    tasks->tasks[ntaskactivitycnt].attempted_ind = 1
   ELSE
    CALL echo("none of the above")
   ENDIF
   tasks->tasks[ntaskactivitycnt].process_ind = 1, tasks->tasks[ntaskactivitycnt].task_description =
   ot.task_description
  FOOT  ta.task_id
   stat = alterlist(tasks->tasks,ntaskactivitycnt)
  WITH nocounter
 ;end select
 CALL echorecord(tasks)
 IF (value(size(tasks->tasks,5)) > 0)
  SET done = 0
  WHILE (done=0)
   SET done = 1
   SELECT INTO "nl:"
    next_cs_id = o.cs_order_id
    FROM (dummyt d1  WITH seq = value(size(tasks->tasks,5))),
     orders o
    PLAN (d1
     WHERE (tasks->tasks[d1.seq].process_ind=1)
      AND (tasks->tasks[d1.seq].cs_order_id > 0.0))
     JOIN (o
     WHERE (o.order_id=tasks->tasks[d1.seq].cs_order_id))
    DETAIL
     IF (o.cs_order_id != 0)
      done = 0, tasks->tasks[d1.seq].cs_order_id = o.cs_order_id
     ELSE
      tasks->tasks[d1.seq].cs_catalog_cd = o.catalog_cd
     ENDIF
    WITH nocounter
   ;end select
  ENDWHILE
  SELECT INTO "nl:"
   ce.charge_event_id
   FROM charge_event ce,
    (dummyt d1  WITH seq = value(size(tasks->tasks,5)))
   PLAN (d1
    WHERE (tasks->tasks[d1.seq].process_ind=1))
    JOIN (ce
    WHERE (((ce.ext_m_event_id=tasks->tasks[d1.seq].cs_order_id)
     AND (ce.ext_m_reference_id=tasks->tasks[d1.seq].cs_catalog_cd)
     AND (ce.ext_p_event_id=tasks->tasks[d1.seq].order_id)
     AND (ce.ext_p_reference_id=tasks->tasks[d1.seq].catalog_cd)
     AND (ce.ext_i_event_id=tasks->tasks[d1.seq].task_id)
     AND (ce.ext_i_reference_id=tasks->tasks[d1.seq].reference_task_id)) OR ((ce.ext_m_event_id=tasks
    ->tasks[d1.seq].task_id)
     AND (ce.ext_m_reference_id=tasks->tasks[d1.seq].reference_task_id)
     AND ce.ext_p_event_id=0.0
     AND (ce.ext_p_reference_id=tasks->tasks[d1.seq].catalog_cd)
     AND (ce.ext_i_event_id=tasks->tasks[d1.seq].task_id)
     AND (ce.ext_i_reference_id=tasks->tasks[d1.seq].reference_task_id))) )
   DETAIL
    tasks->tasks[d1.seq].ce_id = ce.charge_event_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_event_act cea,
    (dummyt d1  WITH seq = value(size(tasks->tasks,5)))
   PLAN (d1
    WHERE (tasks->tasks[d1.seq].complete_ind=1)
     AND (tasks->tasks[d1.seq].process_ind=1)
     AND (tasks->tasks[d1.seq].ce_id != 0))
    JOIN (cea
    WHERE (cea.charge_event_id=tasks->tasks[d1.seq].ce_id)
     AND cea.cea_type_cd=13029_complete
     AND cea.active_ind=1)
   DETAIL
    tasks->tasks[d1.seq].process_ind = 0, tasks->tasks[d1.seq].ce_complete_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cea.charge_event_act_id
   FROM charge_event_act cea,
    (dummyt d1  WITH seq = value(size(tasks->tasks,5)))
   PLAN (d1
    WHERE (tasks->tasks[d1.seq].attempted_ind=1)
     AND (tasks->tasks[d1.seq].process_ind=1)
     AND (tasks->tasks[d1.seq].ce_id != 0))
    JOIN (cea
    WHERE (cea.charge_event_id=tasks->tasks[d1.seq].ce_id)
     AND cea.cea_type_cd=13029_attempted
     AND cea.active_ind=1)
   DETAIL
    tasks->tasks[d1.seq].process_ind = 0, tasks->tasks[d1.seq].ce_attempted_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM person p,
    (dummyt d1  WITH seq = value(size(tasks->tasks,5)))
   PLAN (d1
    WHERE (tasks->tasks[d1.seq].process_ind=1))
    JOIN (p
    WHERE (p.person_id=tasks->tasks[d1.seq].person_id))
   DETAIL
    tasks->tasks[d1.seq].name_full_formatted = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
#end_program
END GO
