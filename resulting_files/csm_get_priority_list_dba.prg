CREATE PROGRAM csm_get_priority_list:dba
 SET reply->status_data.status = "F"
 IF (validate(request->show_inactive_ind,99) != 99)
  IF ((request->show_inactive_ind=1))
   SET v_active_str = "cp.csm_active_ind in (0,1)"
  ELSE
   SET v_active_str = "cp.csm_active_ind = 1"
  ENDIF
 ELSE
  SET v_active_str = "cp.csm_active_ind = 1"
 ENDIF
 SELECT DISTINCT INTO "nl:"
  csm_priority = cp.csm_prior_desc
  FROM csm_priorities cp
  WHERE parser(v_active_str)
   AND cp.csm_prior_id != 0
  ORDER BY csm_priority
  HEAD REPORT
   v_priority_count = 0
  DETAIL
   v_priority_count = (v_priority_count+ 1), stat = alterlist(reply->datacoll,v_priority_count),
   reply->datacoll[v_priority_count].description = cp.csm_prior_desc,
   reply->datacoll[v_priority_count].currcv = trim(build2(cp.csm_prior_id),3)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
