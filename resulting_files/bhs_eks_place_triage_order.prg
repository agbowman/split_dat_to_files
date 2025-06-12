CREATE PROGRAM bhs_eks_place_triage_order
 PROMPT
  " Enter Clinical Event ID: " = 0.00,
  "Enter New Procedure Name: " = ""
 SUBROUTINE eks_order_new(procedure,priority,code,chartyn,comment)
   SET tname = "EKS_ORDER_NEW"
   SET retval = 0
   EXECUTE eks_t_order_action
   RETURN(retval)
 END ;Subroutine
 FREE RECORD work
 RECORD work(
   1 provider = vc
   1 provider_id = f8
   1 new_order
     2 procedure = vc
   1 old_task
     2 order_id = f8
     2 task_id = f8
     2 ref_str = vc
     2 form_id = f8
   1 new_task
     2 order_id = f8
     2 task_id = f8
     2 catalog_type_cd = f8
     2 reference_task_id = f8
     2 task_type_cd = f8
     2 task_class_cd = f8
     2 catalog_cd = f8
     2 scheduled_dt_tm = dq8
 )
 SET work->new_order.procedure = trim( $2,3)
 SET log_message = build2("Clinical Event ID = ",trim(build2(cnvtreal( $1)),3))
 SET retval = - (1)
 DECLARE cs72_provider_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PROVIDER"))
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_mod1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs8_mod2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs79_deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"DELETED"))
 SELECT INTO "NL:"
  FROM clinical_event ce,
   dcp_forms_activity dfa,
   task_activity ta
  PLAN (ce
   WHERE ce.clinical_event_id=cnvtreal( $1)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (dfa
   WHERE cnvtreal(substring(1,(findstring(".00",ce.reference_nbr) - 1),ce.reference_nbr))=dfa
   .dcp_forms_activity_id)
   JOIN (ta
   WHERE dfa.task_id=ta.task_id)
  DETAIL
   work->old_task.ref_str = substring(1,(findstring(".00",ce.reference_nbr)+ 3),ce.reference_nbr),
   work->old_task.form_id = cnvtreal(work->old_task.ref_str), work->old_task.ref_str = concat(work->
    old_task.ref_str,"*"),
   work->old_task.order_id = ta.order_id, work->old_task.task_id = ta.task_id
  WITH nocounter
 ;end select
 IF ((work->old_task.form_id <= 0.00))
  SET log_message = build2(log_message," | Invalid CLINICAL_EVENT_ID")
  SET retval = - (1)
  GO TO exit_script
 ELSE
  SET log_message = build2(log_message," | ","OLD_FORM_ID = ",trim(build2(work->old_task.form_id),3),
   " | ",
   "OLD_TASK_ID = ",trim(build2(work->old_task.task_id),3))
 ENDIF
 SELECT INTO "NL:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.reference_nbr=patstring(work->old_task.ref_str)
    AND ce.event_cd=cs72_provider_cd
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1)
  DETAIL
   work->provider = trim(ce.result_val,3)
  WITH nocounter
 ;end select
 CALL eks_order_new(value(work->new_order.procedure),"ROUTINE","NO CHARGE","chartable",
  "Ordered by Discern Expert")
 SET work->new_task.order_id = eksdata->tqual[4].qual[curindex].order_id
 IF ((work->new_task.order_id <= 0.00))
  SET log_message = build2(log_message," | No order_id logged by EKS_ORDER_NEW")
  SET retval = - (1)
  GO TO exit_script
 ELSE
  SET log_message = build2(log_message," | New ORDER_ID ",trim(build2(work->new_task.order_id),3))
 ENDIF
 IF ((work->provider > " "))
  SELECT INTO "NL:"
   FROM prsnl pr
   PLAN (pr
    WHERE (pr.name_full_formatted=work->provider))
   DETAIL
    work->provider_id = pr.person_id
   WITH nocounter
  ;end select
  IF ((work->provider_id > 1.00))
   UPDATE  FROM order_action oa
    SET oa.order_provider_id = work->provider_id
    WHERE (oa.order_id=work->new_task.order_id)
    WITH nocounter
   ;end update
   IF (curqual <= 0)
    ROLLBACK
    SET log_message = build2(log_message," | Failed to add provider '",work->provider,"' (",trim(
      build2(work->provider_id),3),
     ")")
   ELSE
    COMMIT
    SET log_message = build2(log_message," | Added provider '",work->provider,"' (",trim(build2(work
       ->provider_id),3),
     ")")
   ENDIF
  ENDIF
 ENDIF
 DECLARE lookup_attempts = i4 WITH noconstant(0)
 DECLARE tmp_time = vc
#get_new_task
 SELECT INTO "NL:"
  FROM task_activity ta
  PLAN (ta
   WHERE (ta.order_id=work->new_task.order_id))
  DETAIL
   work->new_task.task_id = ta.task_id, work->new_task.catalog_type_cd = ta.catalog_type_cd, work->
   new_task.reference_task_id = ta.reference_task_id,
   work->new_task.task_type_cd = ta.task_type_cd, work->new_task.task_class_cd = ta.task_class_cd,
   work->new_task.catalog_cd = ta.catalog_cd,
   work->new_task.scheduled_dt_tm = ta.scheduled_dt_tm
  WITH nocounter
 ;end select
 IF ((work->new_task.task_id <= 0.00))
  IF (lookup_attempts < 5)
   SET lookup_attempts = (lookup_attempts+ 1)
   SET tmp_time = format(curtime3,"HHMMSS;;S")
   WHILE (format(curtime3,"HHMMSS;;S")=tmp_time)
     CALL echo("")
   ENDWHILE
   GO TO get_new_task
  ENDIF
  SET log_message = build2(log_message," | Couldn't find task associated with ORDER_ID ",work->
   new_task.order_id)
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 UPDATE  FROM task_activity ta
  SET ta.catalog_type_cd = work->new_task.catalog_type_cd, ta.order_id = work->new_task.order_id, ta
   .reference_task_id = work->new_task.reference_task_id,
   ta.task_type_cd = work->new_task.task_type_cd, ta.task_class_cd = work->new_task.task_class_cd, ta
   .catalog_cd = work->new_task.catalog_cd,
   ta.scheduled_dt_tm = cnvtdatetime(work->new_task.scheduled_dt_tm)
  WHERE (ta.task_id=work->old_task.task_id)
  WITH nocounter
 ;end update
 COMMIT
 UPDATE  FROM task_activity ta
  SET ta.catalog_type_cd = 0.00, ta.order_id = 0.00, ta.task_status_cd = cs79_deleted_cd,
   ta.catalog_cd = 0.00
  WHERE (ta.task_id=work->new_task.task_id)
  WITH nocounter
 ;end update
 COMMIT
 SET retval = 100
 SET log_message = build2(log_message," | ","NEW_ORDER_ID = ",trim(build2(work->new_task.order_id),3),
  " | ",
  "NEW_TASK_ID = ",trim(build2(work->new_task.task_id),3))
#exit_script
 SET log_message = build2(log_message,". Exitting Script")
 CALL echo(build2("RETVAL = ",retval))
 CALL echo(build2("LOG_MESSAGE = ",log_message))
END GO
