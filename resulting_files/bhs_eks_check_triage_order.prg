CREATE PROGRAM bhs_eks_check_triage_order
 PROMPT
  "Enter Clinical Event ID: " = 0.00
 IF (validate(eksevent,"A")="A"
  AND validate(eksevent,"Z")="Z")
  DECLARE log_message = vc
  DECLARE log_misc1 = vc
  DECLARE retval = i2
 ENDIF
 SET log_message = build2("Clinical Event ID = ",trim(build2(cnvtreal( $1)),3))
 SET retval = - (1)
 FREE RECORD work
 RECORD work(
   1 call_category = vc
   1 chart_request_ind = i2
   1 chart_returned_ind = i2
   1 chart_lost_ind = i2
   1 urgent_ind = i2
   1 provider = vc
   1 provider_id = f8
   1 new_order
     2 catalog_cd = f8
     2 needed_ind = i2
     2 procedure = vc
     2 urgent_procedure = vc
   1 old_task
     2 order_id = f8
     2 task_id = f8
     2 ref_str = vc
     2 form_id = f8
 )
 DECLARE get_old_task_info(zero=i2) = null
 DECLARE cs72_call_category_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CALLCATEGORY"))
 DECLARE cs72_chart_request_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CHARTREQUEST"))
 DECLARE cs72_provider_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PROVIDER"))
 DECLARE cs72_urgent_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MESSAGELEVEL"))
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_mod1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs8_mod2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs79_deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"DELETED"))
 DECLARE loop_cnt = i4
 DECLARE var_time = vc
 SUBROUTINE get_old_task_info(zero)
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
     work->old_task.form_id = cnvtreal(work->old_task.ref_str), work->old_task.ref_str = concat(work
      ->old_task.ref_str,"*"),
     work->old_task.order_id = ta.order_id, work->old_task.task_id = ta.task_id
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL get_old_task_info(0)
 IF ((work->old_task.form_id <= 0.00))
  SET loop_cnt = 1
  WHILE (loop_cnt < 3
   AND (work->old_task.form_id <= 0.00))
    SET loop_cnt = (loop_cnt+ 1)
    SET var_time = format(curtime3,"HHMMSS;;M")
    WHILE (format(curtime3,"HHMMSS;;M")=var_time)
      CALL pause(1)
    ENDWHILE
    CALL get_old_task_info(0)
  ENDWHILE
 ENDIF
 IF ((work->old_task.form_id <= 0.00))
  SET log_message = build2(log_message," | Invalid CLINICAL_EVENT_ID")
  SET retval = 0
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
    AND ce.event_cd IN (cs72_call_category_cd, cs72_chart_request_cd, cs72_provider_cd,
   cs72_urgent_cd)
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1)
  DETAIL
   IF (ce.event_cd=cs72_call_category_cd)
    work->call_category = trim(ce.result_val,3), work->new_order.procedure = build2(work->
     call_category," (Phone Triage)")
   ELSEIF (ce.event_cd=cs72_chart_request_cd)
    IF (ce.result_val="Requested")
     work->chart_request_ind = 1
    ELSEIF (ce.result_val="Returned")
     work->chart_returned_ind = 1
    ELSEIF (ce.result_val="Lost")
     work->chart_lost_ind = 1
    ENDIF
   ELSEIF (ce.event_cd=cs72_provider_cd)
    work->provider = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=cs72_urgent_cd)
    IF (ce.result_val="Urgent")
     work->urgent_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((work->call_category <= " "))
  SET log_message = build2(log_message," | No Call Category (EVENT_CD ",trim(build2(
     cs72_call_category_cd),3),") found")
  SET retval = 0
  GO TO exit_script
 ELSE
  SET log_message = build2(log_message," | Call Category '",trim(work->call_category),"'")
 ENDIF
 IF ((work->chart_request_ind=1))
  SET work->new_order.procedure = "Chart Request (Phone Triage)"
 ELSEIF ((work->chart_returned_ind=1))
  SET work->new_order.procedure = "Chart Returned (Phone Triage)"
 ELSEIF ((work->chart_lost_ind=1))
  SET work->new_order.procedure = "Chart Lost (Phone Triage)"
 ENDIF
 SELECT INTO "NL:"
  FROM order_catalog oc,
   order_task_xref otx,
   order_task ot
  PLAN (oc
   WHERE (oc.primary_mnemonic=work->new_order.procedure))
   JOIN (otx
   WHERE oc.catalog_cd=otx.catalog_cd)
   JOIN (ot
   WHERE otx.reference_task_id=ot.reference_task_id)
  DETAIL
   work->new_order.urgent_procedure = build2("Urgent - ",trim(replace(uar_get_code_display(ot
       .task_type_cd),"Phone Triage - ",""),3)," (Phone Triage)")
   IF ((work->urgent_ind=1))
    work->new_order.procedure = work->new_order.urgent_procedure
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM order_catalog oc
  PLAN (oc
   WHERE (oc.primary_mnemonic=work->new_order.procedure))
  DETAIL
   work->new_order.catalog_cd = oc.catalog_cd
  WITH nocounter
 ;end select
 IF ((work->new_order.catalog_cd <= 0.00))
  SET log_message = build2(log_message," | No ORDER found for mnemonic '",work->new_order.procedure,
   "'")
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 SET log_misc1 = work->new_order.procedure
 IF (trim(work->provider,3) > " ")
  SELECT INTO "NL:"
   FROM prsnl pr
   PLAN (pr
    WHERE (pr.name_full_formatted=work->provider))
   DETAIL
    work->provider_id = pr.person_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((work->provider_id <= 0.00))
  SET work->provider = "SYSTEM"
  SET work->provider_id = 1.00
 ENDIF
 SET log_message = build2(log_message," | Provider '",work->provider,"' (",trim(build2(work->
    provider_id),3),
  ")")
 SELECT INTO "NL:"
  o.order_id
  FROM orders o,
   order_action oa,
   prsnl pr
  PLAN (o
   WHERE (o.order_id=work->old_task.order_id)
    AND o.order_id > 0.00)
   JOIN (oa
   WHERE o.order_id=oa.order_id
    AND oa.action_sequence=1)
   JOIN (pr
   WHERE oa.order_provider_id=pr.person_id)
  HEAD o.order_id
   IF ((oa.order_provider_id != work->provider_id))
    work->new_order.needed_ind = 1, log_message = build2(log_message,
     " | Ordering Provider changed from '",trim(pr.name_full_formatted,3),"' (",trim(build2(work->
       provider_id),3),
     ")")
   ENDIF
   IF ((o.catalog_cd != work->new_order.catalog_cd))
    work->new_order.needed_ind = 1, log_message = build2(log_message,
     " | Order Catalog changed from '",trim(o.order_mnemonic,3),"' (",trim(build2(o.catalog_cd),3),
     ") to '",trim(work->new_order.procedure,3),"' (",trim(build2(work->new_order.catalog_cd),3),")")
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET work->new_order.needed_ind = 1
  SET log_message = build2(log_message," | No order found for task. New order needed")
 ENDIF
 IF ((work->new_order.needed_ind=0))
  SET log_message = build2(log_message," | No new order needed")
  SET retval = 0
  GO TO exit_script
 ENDIF
 SET retval = 100
#exit_script
 SET log_message = build2(log_message,". Exitting Script")
 CALL echo(build2("RETVAL = ",retval))
 CALL echo(build2("LOG_MESSAGE = ",log_message))
END GO
