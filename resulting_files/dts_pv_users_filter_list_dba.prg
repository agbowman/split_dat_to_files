CREATE PROGRAM dts_pv_users_filter_list:dba
 SET reply->status_data.status = "F"
 SET v_cv_count = 0
 SET context->start_value = cnvtalphanum(context->start_value)
 SET request->start_value = cnvtalphanum(request->start_value)
 SELECT
  IF (context_ind=1)
   WHERE p.position_cd != 0
    AND p.active_ind=1
    AND p.position_cd=ag.position_cd
    AND ag.app_group_cd=ta.app_group_cd
    AND ((ta.task_number=952250) OR (ta.task_number=4140002))
    AND ((concat(p.name_last_key,p.name_first_key) > cnvtupper(context->start_value)
    AND concat(p.name_last_key,p.name_first_key)=value(concat(cnvtupper(request->start_value),"*")))
    OR (concat(p.name_last_key,p.name_first_key)=cnvtupper(context->start_value)
    AND (((p.name_first_key > context->string1)) OR ((p.name_first_key=context->string1)
    AND (p.person_id > context->num1))) ))
  ELSE
   WHERE p.position_cd != 0
    AND p.active_ind=1
    AND p.position_cd=ag.position_cd
    AND ag.app_group_cd=ta.app_group_cd
    AND ((ta.task_number=952250) OR (ta.task_number=4140002))
    AND concat(p.name_last_key,p.name_first_key)=value(concat(cnvtupper(request->start_value),"*"))
  ENDIF
  DISTINCT INTO "nl:"
  p.person_id, name_full = concat(trim(p.name_last_key,3),", ",trim(p.name_first_key,3))
  FROM prsnl p,
   task_access ta,
   application_group ag
  ORDER BY p.name_last_key, p.name_first_key
  DETAIL
   v_cv_count = (v_cv_count+ 1), stat = alterlist(reply->datacoll,v_cv_count), reply->datacoll[
   v_cv_count].description = name_full,
   reply->datacoll[v_cv_count].currcv = trim(build2(p.person_id),3)
   IF (v_cv_count=maxqualrows)
    context->context_ind = (context->context_ind+ 1), context->start_value = concat(p.name_last_key,p
     .name_first_key), context->string1 = p.name_first_key,
    context->num1 = p.person_id, context->maxqual = maxqualrows
   ENDIF
  WITH nocounter, maxqual(p,value(maxqualrows))
 ;end select
END GO
