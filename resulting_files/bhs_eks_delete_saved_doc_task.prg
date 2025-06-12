CREATE PROGRAM bhs_eks_delete_saved_doc_task
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter CLINICAL_EVENT_ID" = "0.00"
  WITH outdev, clinevent_id
 DECLARE eks_ind = i2 WITH noconstant(1)
 DECLARE ce_event_id = f8
 DECLARE ce_updt_prsnl_id = f8
 DECLARE check_for_tasks(zero1=i2) = null
 DECLARE check_for_event_prsnl(zero2=i2) = null
 DECLARE attempt_cnt = i4
 DECLARE wait_timer = c6
 DECLARE cs6027_saved_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",6027,"SAVED DOC"))
 DECLARE cs21_sign_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE cs103_deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"DELETED"))
 DECLARE cs79_complete_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE cs79_deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"DELETED"))
 DECLARE cs48_deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"DELETED"))
 DECLARE var_system_comment = vc WITH constant(build2("Marked as deleted by Discern Rule (",curprog,
   ")"))
 SUBROUTINE check_for_tasks(zero1)
   SET ce_event_id = 0.00
   SET ce_updt_prsnl_id = 0.00
   SELECT INTO "NL:"
    FROM clinical_event ce,
     task_activity ta
    PLAN (ce
     WHERE ce.clinical_event_id=cnvtreal( $CLINEVENT_ID))
     JOIN (ta
     WHERE ce.event_id=ta.event_id
      AND ta.task_activity_cd=cs6027_saved_doc_cd
      AND  NOT (ta.task_status_cd IN (cs79_complete_cd, cs79_deleted_cd))
      AND ta.active_ind=1
      AND  EXISTS (
     (SELECT
      taa.task_id
      FROM task_activity_assignment taa
      WHERE ta.task_id=taa.task_id
       AND ce.updt_id=taa.assign_prsnl_id
       AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3))))
    DETAIL
     ce_event_id = ce.event_id, ce_updt_prsnl_id = ce.updt_id, attempt_cnt = 999,
     work->t_cnt = (work->t_cnt+ 1), stat = alterlist(work->tasks,work->t_cnt), work->tasks[work->
     t_cnt].task_id = ta.task_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE check_for_event_prsnl(zero2)
   SET ce_event_id = 0.00
   SET ce_updt_prsnl_id = 0.00
   SELECT INTO "NL:"
    FROM clinical_event ce,
     ce_event_prsnl cep
    PLAN (ce
     WHERE ce.clinical_event_id=cnvtreal( $CLINEVENT_ID))
     JOIN (cep
     WHERE ce.event_id=cep.event_id
      AND ce.updt_id=cep.action_prsnl_id
      AND cep.action_type_cd=cs21_sign_cd
      AND cep.action_dt_tm=null
      AND cep.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
      AND cep.action_status_cd != cs103_deleted_cd)
    DETAIL
     attempt_cnt = 999, ce_event_id = cep.event_id, ce_updt_prsnl_id = cep.action_prsnl_id
    WITH nocounter
   ;end select
 END ;Subroutine
 RECORD work(
   1 error_ind = i2
   1 t_cnt = i4
   1 tasks[*]
     2 task_id = f8
     2 updt_status = i2
 )
 IF (validate(eksevent,"A")="A"
  AND validate(eksevent,"Z")="Z")
  DECLARE log_message = vc
  DECLARE retval = i4 WITH noconstant(- (1))
  DECLARE log_misc1 = vc
  SET eks_ind = 0
 ENDIF
 SET log_message = build2("CLINICAL_EVENT_ID: ",trim(build2(cnvtreal( $CLINEVENT_ID)),3))
 SET retval = 0
 SET attempt_cnt = 0
 CALL check_for_event_prsnl(0)
 WHILE (attempt_cnt < 1)
   SET attempt_cnt = (attempt_cnt+ 1)
   SET wait_timer = format(curtime3,"HHMMSS;;M")
   WHILE (format(curtime3,"HHMMSS;;M")=wait_timer)
     CALL pause(1)
   ENDWHILE
   CALL check_for_event_prsnl(0)
 ENDWHILE
 IF (attempt_cnt < 999)
  SET log_message = build2(log_message," | No sign requests (code value ",trim(build2(cs21_sign_cd),3
    ),") found.")
  GO TO exit_script
 ELSE
  SET log_message = build2(log_message," | ",trim(build2(curqual),3),
   " sign requests found for PRSNL_ID ",trim(build2(ce_updt_prsnl_id),3))
 ENDIF
 UPDATE  FROM ce_event_prsnl cep
  SET cep.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), cep.action_status_cd = cs103_deleted_cd,
   cep.system_comment = var_system_comment
  WHERE cep.event_id=ce_event_id
   AND cep.action_prsnl_id=ce_updt_prsnl_id
   AND cep.action_type_cd=cs21_sign_cd
   AND cep.action_dt_tm=null
   AND cep.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
   AND cep.action_status_cd != cs103_deleted_cd
  WITH nocounter
 ;end update
 IF (curqual <= 0)
  SET log_message = build2(log_message," ~ No CE_EVENT_PRSNL rows updated. ","Updates rolled back.")
  SET retval = - (1)
 ELSE
  SET log_message = build2(log_message," ~ ",trim(build2(curqual),3)," CE_EVENT_PRSNL row(s) updated"
   )
  IF ((retval > - (1)))
   SET retval = 100
  ENDIF
 ENDIF
 SET attempt_cnt = 0
 CALL check_for_tasks(0)
 WHILE (attempt_cnt < 5)
   SET attempt_cnt = (attempt_cnt+ 1)
   SET wait_timer = format(curtime3,"HHMMSS;;M")
   WHILE (format(curtime3,"HHMMSS;;M")=wait_timer)
     CALL pause(1)
   ENDWHILE
   CALL check_for_tasks(0)
 ENDWHILE
 IF (attempt_cnt < 999)
  SET log_message = build2(log_message," | No saved document (code value ",trim(build2(
     cs6027_saved_doc_cd),3),") tasks found.")
 ELSE
  SET log_message = build2(log_message," | CE_EVENT_ID = ",trim(build2(ce_event_id),3),
   " | Following saved document task(s) found for PRSNL_ID ",trim(build2(ce_updt_prsnl_id),3),
   ":")
  FOR (t = 1 TO work->t_cnt)
    IF (t=1)
     SET log_message = build2(log_message," ",trim(build2(work->tasks[t].task_id),3))
    ELSE
     SET log_message = build2(log_message,", ",trim(build2(work->tasks[t].task_id),3))
    ENDIF
  ENDFOR
 ENDIF
 FOR (t = 1 TO work->t_cnt)
   SET log_message = build2(log_message," | Processing TASK_ID ",trim(build2(work->tasks[t].task_id),
     3))
   SET work->tasks[t].updt_status = 1
   IF ((work->tasks[t].updt_status=1))
    UPDATE  FROM task_activity_assignment taa
     SET taa.task_status_cd = cs79_deleted_cd, taa.end_eff_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (taa.task_id=work->tasks[t].task_id)
      AND taa.assign_prsnl_id=ce_updt_prsnl_id
     WITH nocounter, status(work->tasks[t].updt_status)
    ;end update
    IF ((work->tasks[t].updt_status != 1))
     SET log_message = build2(log_message," ~ Error updating TASK_ACTIVITY_ASSIGNMENT. ",
      "Updates for TASK_ID ",trim(build2(work->tasks[t].task_id),3)," rolled back.")
    ELSE
     SET log_message = build2(log_message," ~ ",trim(build2(curqual),3),
      " TASK_ACTIVITY_ASSIGNMENT row(s) updated")
    ENDIF
   ENDIF
   IF ((work->tasks[t].updt_status=1))
    UPDATE  FROM task_activity ta
     SET ta.task_status_cd = cs79_deleted_cd, ta.active_ind = 0, ta.active_status_cd =
      cs48_deleted_cd
     WHERE (ta.task_id=work->tasks[t].task_id)
     WITH nocounter, status(work->tasks[t].updt_status)
    ;end update
    IF ((work->tasks[t].updt_status != 1))
     SET log_message = build2(log_message," ~ Error updating TASK_ACTIVITY. ","Updates for TASK_ID ",
      trim(build2(work->tasks[t].task_id),3)," rolled back.")
    ELSE
     SET log_message = build2(log_message," ~ ",trim(build2(curqual),3),
      " TASK_ACTIVITY row(s) updated")
    ENDIF
   ENDIF
   IF ((work->tasks[t].updt_status=1))
    COMMIT
   ELSE
    SET work->error_ind = 1
    ROLLBACK
   ENDIF
 ENDFOR
 IF ((work->t_cnt > 0))
  IF ((work->error_ind=1))
   SET log_message = build2(log_message," | Not all updates successful")
   SET retval = - (1)
  ELSE
   SET log_message = build2(log_message," | All task activity updates completed successfully")
   IF ((retval > - (1)))
    SET retval = 100
   ENDIF
  ENDIF
 ENDIF
#exit_script
 SET log_message = build2(log_message," | Exitting Script")
 IF (eks_ind=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    cur_row = 0
   DETAIL
    IF (size(trim(log_message,3)) > 128)
     col 0,
     CALL print(substring(1,128,log_message)), row + 1,
     cur_row = 1
     WHILE (((size(trim(log_message,3)) - (cur_row * 128)) > 0))
       col 0,
       CALL print(substring(((cur_row * 128)+ 1),128,log_message)), row + 1,
       cur_row = (cur_row+ 1)
     ENDWHILE
    ELSE
     row + 1, col 0,
     CALL print(substring(1,128,log_message))
    ENDIF
    row + 1, col 0,
    CALL print(build2("RETVAL = ",trim(build2(retval),3)))
   WITH nocounter
  ;end select
 ENDIF
 FREE SET eks_ind
 FREE SET ce_event_id
 FREE SET ta_task_id
 FREE SET cs6027_saved_doc_cd
 FREE SET cs21_sign_cd
 FREE SET cs103_deleted_cd
 FREE SET cs79_deleted_cd
 FREE SET cs48_deleted_cd
END GO
