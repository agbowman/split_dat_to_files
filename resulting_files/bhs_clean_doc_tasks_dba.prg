CREATE PROGRAM bhs_clean_doc_tasks:dba
 FREE RECORD cleanup
 RECORD cleanup(
   1 cleanup_list[*]
     2 task_id = f8
     2 task_activity_cd = f8
     2 assign_prsnl_id = f8
     2 event_class_cd = f8
 )
 DECLARE in_progress_result_status = f8 WITH constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE perform_action_type = f8 WITH constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE review_action_type = f8 WITH constant(uar_get_code_by("MEANING",21,"REVIEW"))
 DECLARE sign_action_type = f8 WITH constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE saved_doc_task_activity = f8 WITH constant(uar_get_code_by("MEANING",6027,"SAVED DOC"))
 DECLARE review_task_activity = f8 WITH constant(uar_get_code_by("MEANING",6027,"REVIEW RESUL"))
 DECLARE sign_task_activity = f8 WITH constant(uar_get_code_by("MEANING",6027,"SIGN RESULT"))
 DECLARE perf_task_activity = f8 WITH constant(uar_get_code_by("MEANING",6027,"PERF RESULT"))
 DECLARE completed_action_status = f8 WITH constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE pending_task_status = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE opened_task_status = f8 WITH constant(uar_get_code_by("MEANING",79,"OPENED"))
 DECLARE complete_task_status = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE on_hold_task_status = f8 WITH constant(uar_get_code_by("MEANING",79,"ONHOLD"))
 DECLARE endorse_task_type = f8 WITH constant(uar_get_code_by("MEANING",6026,"ENDORSE"))
 DECLARE doc_event_class = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE mdoc_event_class = f8 WITH constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE grpdoc_event_class = f8 WITH constant(uar_get_code_by("MEANING",53,"GRPDOC"))
 DECLARE task_count = i4 WITH noconstant(0)
 DECLARE begin_dt_tm = dq8
 DECLARE end_dt_tm = dq8
 SET begin_dt_tm = cnvtdatetime(concat(format(datetimeadd(sysdate,- (1)),"dd-mmm-yyyy;;d"),
   " 00:00:00"))
 CALL echo(build2("begin date: ",trim(format(begin_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))))
 SET end_dt_tm = cnvtdatetime(concat(format(datetimeadd(sysdate,- (1)),"dd-mmm-yyyy;;d")," 23:59:59")
  )
 CALL echo(build2("end_date: ",trim(format(end_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))))
 CALL echo("gathering tasks")
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   clinical_event ce,
   ce_event_prsnl cep,
   task_activity ta
  PLAN (ta
   WHERE ta.task_type_cd=endorse_task_type
    AND ta.task_activity_cd=saved_doc_task_activity
    AND ta.task_status_cd IN (pending_task_status, opened_task_status, on_hold_task_status)
    AND ta.task_create_dt_tm >= cnvtdatetime(begin_dt_tm)
    AND ta.task_create_dt_tm <= cnvtdatetime(end_dt_tm)
    AND ta.event_class_cd IN (doc_event_class, grpdoc_event_class, mdoc_event_class))
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND taa.task_status_cd IN (pending_task_status, opened_task_status, on_hold_task_status))
   JOIN (cep
   WHERE cep.event_id=ta.event_id
    AND cep.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ((cep.action_type_cd+ 0)=perform_action_type)
    AND ((cep.action_status_cd+ 0)=completed_action_status)
    AND ((cep.action_prsnl_id+ 0)=taa.assign_prsnl_id))
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ((ce.result_status_cd+ 0) != in_progress_result_status)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY ta.task_id
  HEAD ta.task_id
   task_count = (task_count+ 1)
   IF (task_count > size(cleanup->cleanup_list,5))
    stat = alterlist(cleanup->cleanup_list,(task_count+ 10))
   ENDIF
   cleanup->cleanup_list[task_count].task_id = ta.task_id, cleanup->cleanup_list[task_count].
   task_activity_cd = ta.task_activity_cd, cleanup->cleanup_list[task_count].assign_prsnl_id = taa
   .assign_prsnl_id,
   cleanup->cleanup_list[task_count].event_class_cd = ta.event_class_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   clinical_event ce,
   ce_event_prsnl cep,
   task_activity ta
  PLAN (ta
   WHERE ta.task_type_cd=endorse_task_type
    AND ta.task_activity_cd=perf_task_activity
    AND ta.task_status_cd IN (pending_task_status, opened_task_status, on_hold_task_status)
    AND ta.task_create_dt_tm >= cnvtdatetime(begin_dt_tm)
    AND ta.task_create_dt_tm <= cnvtdatetime(end_dt_tm)
    AND ta.event_class_cd IN (doc_event_class, grpdoc_event_class, mdoc_event_class))
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND taa.task_status_cd IN (pending_task_status, opened_task_status, on_hold_task_status))
   JOIN (cep
   WHERE cep.event_id=ta.event_id
    AND cep.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ((cep.action_type_cd+ 0)=perform_action_type)
    AND ((cep.action_status_cd+ 0)=completed_action_status)
    AND ((cep.action_prsnl_id+ 0)=taa.assign_prsnl_id))
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ((ce.result_status_cd+ 0) != in_progress_result_status)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY ta.task_id
  HEAD ta.task_id
   task_count = (task_count+ 1)
   IF (task_count > size(cleanup->cleanup_list,5))
    stat = alterlist(cleanup->cleanup_list,(task_count+ 10))
   ENDIF
   cleanup->cleanup_list[task_count].task_id = ta.task_id, cleanup->cleanup_list[task_count].
   task_activity_cd = ta.task_activity_cd, cleanup->cleanup_list[task_count].assign_prsnl_id = taa
   .assign_prsnl_id,
   cleanup->cleanup_list[task_count].event_class_cd = ta.event_class_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   clinical_event ce,
   ce_event_prsnl cep,
   task_activity ta
  PLAN (ta
   WHERE ta.task_type_cd=endorse_task_type
    AND ta.task_activity_cd=sign_task_activity
    AND ta.task_status_cd IN (pending_task_status, opened_task_status, on_hold_task_status)
    AND ta.task_create_dt_tm >= cnvtdatetime(begin_dt_tm)
    AND ta.task_create_dt_tm <= cnvtdatetime(end_dt_tm)
    AND ta.event_class_cd IN (doc_event_class, grpdoc_event_class, mdoc_event_class))
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND taa.task_status_cd IN (pending_task_status, opened_task_status, on_hold_task_status))
   JOIN (cep
   WHERE cep.event_id=ta.event_id
    AND cep.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ((cep.action_type_cd+ 0)=sign_action_type)
    AND ((cep.action_status_cd+ 0)=completed_action_status)
    AND ((cep.action_prsnl_id+ 0)=taa.assign_prsnl_id))
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ((ce.result_status_cd+ 0) != in_progress_result_status)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY ta.task_id
  HEAD ta.task_id
   task_count = (task_count+ 1)
   IF (task_count > size(cleanup->cleanup_list,5))
    stat = alterlist(cleanup->cleanup_list,(task_count+ 10))
   ENDIF
   cleanup->cleanup_list[task_count].task_id = ta.task_id, cleanup->cleanup_list[task_count].
   task_activity_cd = ta.task_activity_cd, cleanup->cleanup_list[task_count].assign_prsnl_id = taa
   .assign_prsnl_id,
   cleanup->cleanup_list[task_count].event_class_cd = ta.event_class_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   clinical_event ce,
   ce_event_prsnl cep,
   task_activity ta
  PLAN (ta
   WHERE ta.task_type_cd=endorse_task_type
    AND ta.task_activity_cd=review_task_activity
    AND ta.task_status_cd IN (pending_task_status, opened_task_status, on_hold_task_status)
    AND ta.task_create_dt_tm >= cnvtdatetime(begin_dt_tm)
    AND ta.task_create_dt_tm <= cnvtdatetime(end_dt_tm)
    AND ta.event_class_cd IN (doc_event_class, grpdoc_event_class, mdoc_event_class))
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND taa.task_status_cd IN (pending_task_status, opened_task_status, on_hold_task_status))
   JOIN (cep
   WHERE cep.event_id=ta.event_id
    AND cep.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ((cep.action_type_cd+ 0)=review_action_type)
    AND ((cep.action_status_cd+ 0)=completed_action_status)
    AND ((cep.action_prsnl_id+ 0)=taa.assign_prsnl_id))
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ((ce.result_status_cd+ 0) != in_progress_result_status)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY ta.task_id
  HEAD ta.task_id
   task_count = (task_count+ 1)
   IF (task_count > size(cleanup->cleanup_list,5))
    stat = alterlist(cleanup->cleanup_list,(task_count+ 10))
   ENDIF
   cleanup->cleanup_list[task_count].task_id = ta.task_id, cleanup->cleanup_list[task_count].
   task_activity_cd = ta.task_activity_cd, cleanup->cleanup_list[task_count].assign_prsnl_id = taa
   .assign_prsnl_id,
   cleanup->cleanup_list[task_count].event_class_cd = ta.event_class_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(cleanup->cleanup_list,task_count)
 IF (task_count <= 0)
  CALL echo("nothing to update")
  GO TO exit_script
 ELSE
  CALL echo(build2(size(cleanup->cleanup_list,5)," tasks found"))
 ENDIF
 CALL echo("cleaning up tasks...")
 UPDATE  FROM (dummyt d  WITH seq = value(task_count)),
   task_activity ta
  SET ta.task_status_cd = complete_task_status, ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta
   .updt_id = reqinfo->updt_id,
   ta.updt_cnt = (ta.updt_cnt+ 1)
  PLAN (d)
   JOIN (ta
   WHERE (ta.task_id=cleanup->cleanup_list[d.seq].task_id)
    AND ta.active_ind=1)
  WITH nocounter
 ;end update
 UPDATE  FROM (dummyt d  WITH seq = value(task_count)),
   task_activity_assignment taa
  SET taa.task_status_cd = complete_task_status, taa.updt_dt_tm = cnvtdatetime(curdate,curtime3), taa
   .updt_id = reqinfo->updt_id,
   taa.updt_cnt = (taa.updt_cnt+ 1)
  PLAN (d)
   JOIN (taa
   WHERE (taa.task_id=cleanup->cleanup_list[d.seq].task_id)
    AND taa.active_ind=1)
  WITH nocounter
 ;end update
 COMMIT
#exit_script
 CALL echorecord(cleanup)
 FREE RECORD cleanup
END GO
