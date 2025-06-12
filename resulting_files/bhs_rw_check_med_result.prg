CREATE PROGRAM bhs_rw_check_med_result
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
  DECLARE log_orderid = f8
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
 SET log_message = build2("LOG_CLINEVENTID = ",build(log_clineventid)," | LOG_ORDERID = ",build(
   log_orderid))
 IF (trim( $2,3) <= " ")
  SET log_message = "No Task Display given. Exitting Script"
  SET retval = - (1)
  GO TO exit_script
 ELSE
  DECLARE cs14003_task_assay_cd = f8 WITH constant(uar_get_code_by("DISPLAY",14003,trim( $2,3)))
  IF (cs14003_task_assay_cd <= 0.00)
   SET log_message = "Task Display not valid. Exitting Script"
   SET retval = - (1)
   GO TO exit_script
  ELSE
   SET log_message = build2(log_message," | TASK_ASSAY_CD = ",build(cs14003_task_assay_cd))
  ENDIF
 ENDIF
 SET retval = 0
 DECLARE ingredient_ind = i2
 SELECT INTO "NL:"
  FROM orders o,
   task_activity ta,
   task_discrete_r tdr
  PLAN (o
   WHERE log_orderid=o.order_id)
   JOIN (ta
   WHERE outerjoin(o.order_id)=ta.order_id)
   JOIN (tdr
   WHERE outerjoin(ta.reference_task_id)=tdr.reference_task_id
    AND ((tdr.task_assay_cd+ 0)=outerjoin(cs14003_task_assay_cd)))
  DETAIL
   IF (tdr.reference_task_id > 0.00)
    retval = 100
   ELSEIF (o.ingredient_ind=1)
    ingredient_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (ingredient_ind=1)
  SELECT INTO "NL:"
   FROM order_ingredient oi,
    order_task_xref otx,
    task_discrete_r tdr
   PLAN (oi
    WHERE log_orderid=oi.order_id)
    JOIN (otx
    WHERE oi.catalog_cd=otx.catalog_cd)
    JOIN (tdr
    WHERE otx.reference_task_id=tdr.reference_task_id
     AND ((tdr.task_assay_cd+ 0)=cs14003_task_assay_cd))
   DETAIL
    retval = 100
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echo(build2("LOG_MESSAGE = ",log_message))
 CALL echo(build2("RETVAL = ",build(retval)))
END GO
