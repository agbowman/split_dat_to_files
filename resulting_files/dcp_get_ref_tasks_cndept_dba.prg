CREATE PROGRAM dcp_get_ref_tasks_cndept:dba
 SET reply->status_data.status = "F"
 SET v_cv_count = 0
 SET context->start_value = cnvtalphanum(context->start_value)
 SET request->start_value = cnvtalphanum(request->start_value)
 SELECT
  IF (context_ind=1)
   WHERE ot.reference_task_id > 0
    AND ot.active_ind=1
    AND ((cnvtupper(ot.task_description) > cnvtupper(context->start_value)
    AND cnvtupper(ot.task_description)=value(concat(cnvtupper(request->start_value),"*"))) OR (
   cnvtupper(ot.task_description)=cnvtupper(context->start_value)
    AND (ot.reference_task_id > context->num1)))
  ELSE
   WHERE ot.reference_task_id > 0
    AND ot.active_ind=1
    AND cnvtupper(ot.task_description)=value(concat(cnvtupper(request->start_value),"*"))
  ENDIF
  INTO "nl:"
  ot.reference_task_id, ot.task_description, ot.task_type_cd
  FROM order_task ot
  ORDER BY ot.task_description, ot.reference_task_id
  DETAIL
   v_cv_count = (v_cv_count+ 1), stat = alterlist(reply->datacoll,v_cv_count), reply->datacoll[
   v_cv_count].description = ot.task_description,
   reply->datacoll[v_cv_count].currcv = cnvtstring(ot.reference_task_id)
   IF (v_cv_count=maxqualrows)
    context->context_ind = (context->context_ind+ 1), context->start_value = ot.task_description,
    context->num1 = ot.reference_task_id,
    context->maxqual = maxqualrows
   ENDIF
  WITH nocounter, maxqual(p,value(maxqualrows))
 ;end select
END GO
