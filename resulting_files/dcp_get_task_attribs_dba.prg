CREATE PROGRAM dcp_get_task_attribs:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->task_list,5))
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   ta.task_id, p.person_id
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    task_activity ta,
    prsnl p
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_id=request->task_list[d.seq].task_id)
     AND ta.active_ind=1)
    JOIN (p
    WHERE p.person_id=ta.updt_id)
   ORDER BY ta.task_id
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].task_id = ta.task_id, reply->get_list[count1].reference_task_id = ta
    .reference_task_id, reply->get_list[count1].order_id = ta.order_id,
    reply->get_list[count1].catalog_cd = ta.catalog_cd, reply->get_list[count1].catalog_type_cd = ta
    .catalog_type_cd, reply->get_list[count1].task_activity_cd = ta.task_activity_cd,
    reply->get_list[count1].person_id = ta.person_id, reply->get_list[count1].encntr_id = ta
    .encntr_id, reply->get_list[count1].location_cd = ta.location_cd,
    reply->get_list[count1].updt_dt_tm = ta.updt_dt_tm, reply->get_list[count1].updt_id = ta.updt_id,
    reply->get_list[count1].task_status_cd = ta.task_status_cd,
    reply->get_list[count1].task_status_reason_cd = ta.task_status_reason_cd, reply->get_list[count1]
    .iv_ind = ta.iv_ind, reply->get_list[count1].med_order_type_cd = ta.med_order_type_cd,
    reply->get_list[count1].task_class_cd = ta.task_class_cd, reply->get_list[count1].task_dt_tm = ta
    .task_dt_tm
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH check
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
