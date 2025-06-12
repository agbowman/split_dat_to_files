CREATE PROGRAM bhs_rw_add_linked_task
 PROMPT
  "Enter CLINICAL_EVENT_ID: " = 0.00,
  " Enter Task Description: " = ""
 DECLARE find_correct_clineventid(tmp_clineventid=f8) = null
 SUBROUTINE find_correct_clineventid(tmp_clineventid)
   SELECT INTO "NL:"
    FROM clinical_event ce
    PLAN (ce
     WHERE tmp_clineventid=ce.clinical_event_id
      AND ce.order_id > 0.00
      AND ce.task_assay_cd <= 0.00)
    DETAIL
     log_clineventid = ce.clinical_event_id, log_orderid = ce.order_id
    WITH nocounter
   ;end select
 END ;Subroutine
 IF (validate(eksevent,"A")="A"
  AND validate(eksevent,"Z")="Z")
  DECLARE log_message = vc
  DECLARE retval = i4
  DECLARE log_clineventid = f8
  RECORD reply(
    1 status_data
      2 status = c1
  )
  IF (reflect(parameter(1,0)) <= " ")
   SET log_message = build2("No valid CLINICAL_EVENT_ID passed in ($1 = ",trim(build2( $1),4),
    "). Exitting Script")
   SET retval = - (1)
   GO TO exit_script
  ELSEIF (cnvtreal(parameter(1,0)) > 0.00)
   CALL find_correct_clineventid(cnvtreal(parameter(1,0)))
   IF (log_clineventid <= 0.00)
    SET log_message = build2("No CLINICAL_EVENT_ID passed in ($1 = ",trim(build2( $1),4),
     ". Exitting Script")
    SET retval = - (1)
    GO TO exit_script
   ENDIF
  ELSEIF (validate(parameter(1,1),0.00) > 0.00)
   DECLARE subval_slot = i4
   SET subval_slot = 1
   SET log_message = "Looping through multiple CLINICAL_EVENT_IDs..."
   WHILE (validate(parameter(1,subval_slot)) > 0.00
    AND log_clineventid <= 0.00
    AND subval_slot <= 5)
     SET log_message = build2(log_message," | Attempt ",trim(build2(subval_slot),4)," = ",trim(build2
       (cnvtreal(parameter(1,subval_slot))),4))
     CALL find_correct_clineventid(cnvtreal(parameter(1,subval_slot)))
     SET subval_slot = (subval_slot+ 1)
   ENDWHILE
   FREE SET subval_slot
   IF (log_clineventid <= 0.00)
    SET log_message = build2(log_message," | No valid CLINICAL_EVENT_ID passed in. Exitting Script")
    SET retval = - (1)
    GO TO exit_script
   ENDIF
  ELSE
   SET log_message = build2("No valid CLINICAL_EVENT_ID passed in. Exitting Script")
   SET retval = - (1)
   GO TO exit_script
  ENDIF
 ELSE
  IF (link_clineventid <= 0.00
   AND size(request->clin_detail_list,5) <= 1)
   SET log_message = build2("No CLINICAL_EVENT_ID passed in (LINK_CLINEVENTID = ",build(
     link_clineventid),", EVENT_REPEAT_COUNT = ",build(event_repeat_count),
    " SIZE(REQUEST->CLIN_DETAIL_LIST = ",
    build(size(request->clin_detail_list,5)),"). Exitting Script")
   SET retval = - (1)
   GO TO exit_script
  ELSEIF (link_clineventid > 0.00)
   CALL find_correct_clineventid(link_clineventid)
   IF (log_clineventid <= 0.00)
    SET log_message = build2("No CLINICAL_EVENT_ID passed in (LINK_CLINEVENTID = ",build(
      link_clineventid),"). Exitting Script")
    SET retval = - (1)
    GO TO exit_script
   ENDIF
  ELSEIF (size(request->clin_detail_list,5) > 1)
   DECLARE subval_slot = i4
   SET subval_slot = 1
   SET log_message = "Looping through multiple CLINICAL_EVENT_IDs..."
   WHILE (log_clineventid <= 0.00
    AND subval_slot <= size(request->clin_detail_list,5))
     SET log_message = build2(log_message," | Attempt ",build(subval_slot)," = ",build(request->
       clin_detail_list[subval_slot].clinical_event_id))
     CALL find_correct_clineventid(request->clin_detail_list[subval_slot].clinical_event_id)
     SET subval_slot = (subval_slot+ 1)
   ENDWHILE
   FREE SET subval_slot
   IF (log_clineventid <= 0.00)
    SET log_message = build2(log_message," | No valid CLINICAL_EVENT_ID passed in. Exitting Script")
    SET retval = - (1)
    GO TO exit_script
   ENDIF
  ELSE
   SET log_message = build2("No valid CLINICAL_EVENT_ID passed in. Exitting Script")
   SET retval = - (1)
   GO TO exit_script
  ENDIF
 ENDIF
 SET log_message = build2("LOG_CLINEVENTID = ",build(log_clineventid))
 IF (trim(build( $2)) <= " ")
  SET log_message = build2(log_message," | No Task Description given. Exitting Script")
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 FREE RECORD link_request
 RECORD link_request(
   1 task_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 catalog_type_cd = f8
   1 order_id = f8
   1 display_order_id = f8
   1 location_cd = f8
   1 reference_task_id = f8
   1 task_type_cd = f8
   1 task_class_cd = f8
   1 task_status_cd = f8
   1 task_dt_tm = dq8
   1 task_activity_cd = f8
   1 catalog_cd = f8
   1 med_order_type_cd = f8
   1 loc_bed_cd = f8
   1 loc_room_cd = f8
   1 task_tz = i4
   1 scheduled_dt_tm = dq8
   1 prereq_task_id = f8
   1 task_priority_cd = f8
 )
 FREE RECORD link_reqinfo
 RECORD link_reqinfo(
   1 updt_id = f8
   1 updt_task = i4
   1 updt_applctx = f8
 )
 SELECT INTO "NL:"
  ot.reference_task_id, ot.task_type_cd, ot.task_activity_cd
  FROM order_task ot
  PLAN (ot
   WHERE ot.task_description=trim( $2))
  DETAIL
   link_request->reference_task_id = ot.reference_task_id, link_request->task_type_cd = ot
   .task_type_cd, link_request->task_class_cd = uar_get_code_by("MEANING",6025,"SCH"),
   link_request->task_activity_cd = ot.task_activity_cd, link_request->catalog_cd = 0.00
  WITH nocounter
 ;end select
 IF ((link_request->reference_task_id=0.00))
  SET log_message = build2(log_message," | Invalid Task Description given (",trim( $2),
   "). Exitting Script")
  SET retval = - (1)
  GO TO exit_script
 ELSE
  SET log_message = build2(log_message," | REFERENCE_TASK_ID = ",build(link_request->
    reference_task_id))
 ENDIF
 SELECT INTO "NL:"
  ta.task_id, ta.person_id, ta.encntr_id,
  ta.order_id, o.template_order_id, ta.location_cd,
  ta.task_dt_tm, ta.loc_bed_cd, ta.loc_room_cd,
  ta.task_tz
  FROM clinical_event ce,
   task_activity ta,
   orders o
  PLAN (ce
   WHERE ce.clinical_event_id=log_clineventid)
   JOIN (ta
   WHERE ce.order_id=ta.order_id)
   JOIN (o
   WHERE ta.order_id=o.order_id)
  DETAIL
   link_request->prereq_task_id = ta.task_id, link_request->person_id = ta.person_id, link_request->
   encntr_id = ta.encntr_id,
   link_request->order_id = ta.order_id, link_request->location_cd = ta.location_cd, link_request->
   task_dt_tm = cnvtdatetime(format((cnvtdatetime(ce.event_end_dt_tm)+ 36000000000.00),";;Q")),
   link_request->loc_bed_cd = ta.loc_bed_cd, link_request->loc_room_cd = ta.loc_room_cd, link_request
   ->task_tz = ta.task_tz,
   link_request->task_priority_cd = 657972.00
   IF (o.template_order_id > 0.00)
    link_request->display_order_id = o.template_order_id
   ELSE
    link_request->display_order_id = ta.order_id
   ENDIF
   IF (cnvtdatetime(link_request->task_dt_tm) < cnvtdatetime(curdate,curtime3))
    link_request->task_status_cd = uar_get_code_by("MEANING",79,"OVERDUE")
   ELSE
    link_request->task_status_cd = uar_get_code_by("MEANING",79,"PENDING")
   ENDIF
  WITH nocounter
 ;end select
 IF ((link_request->prereq_task_id=0.00))
  SET log_message = build2(log_message," | No task found for CLINICAL_EVENT_ID ",build(
    log_clineventid),". Exitting Script")
  SET retval = - (1)
  GO TO exit_script
 ELSE
  SET log_message = build2(log_message," | PREREQ_TASK_ID = ",build(link_request->prereq_task_id))
 ENDIF
 SELECT INTO "NL:"
  new_id = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   link_request->task_id = new_id
  WITH nocounter
 ;end select
 DECLARE task_id = f8 WITH constant(link_request->task_id), public
 EXECUTE dcp_add_response_task  WITH replace(request,link_request)
 COMMIT
 SET log_message = build2(log_message," | New TASK_ID = ",build(task_id),"| Task_id = ",link_request
  ->task_id,
  "| PREREQ_TASK_ID = ",link_request->prereq_task_id,"| TASK DESCRIPTION = ",trim(build2( $2)))
 FREE SET task_id
 UPDATE  FROM task_reltn tr
  SET tr.display_order_id = link_request->display_order_id
  WHERE (tr.task_id=link_request->task_id)
   AND (tr.prereq_task_id=link_request->prereq_task_id)
  WITH nocounter
 ;end update
 IF (curqual > 0)
  SET log_message = "UPDATE SUCCESSFUL"
  COMMIT
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
#exit_script
 CALL echo(build2("LOG_MESSAGE = ",log_message))
 CALL echo(build2("RETVAL = ",build(retval)))
 CALL echorecord(link_request)
END GO
