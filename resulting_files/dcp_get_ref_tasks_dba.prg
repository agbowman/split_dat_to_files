CREATE PROGRAM dcp_get_ref_tasks:dba
 SET count1 = 0
 SET count2 = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ot.reference_task_id, otp.position_cd
  FROM order_task ot,
   order_task_position_xref otp
  PLAN (ot
   WHERE ot.active_ind=1)
   JOIN (otp
   WHERE (otp.reference_task_id= Outerjoin(ot.reference_task_id)) )
  ORDER BY ot.reference_task_id, otp.position_cd
  HEAD REPORT
   count1 = 0
  HEAD ot.reference_task_id
   count2 = 0, count1 += 1
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].reference_task_id = ot.reference_task_id, reply->get_list[count1].
   task_description = ot.task_description, reply->get_list[count1].task_activity_cd = ot
   .task_activity_cd,
   reply->get_list[count1].chart_not_cmplt_ind = ot.chart_not_cmplt_ind, reply->get_list[count1].
   task_type_cd = ot.task_type_cd, reply->get_list[count1].quick_chart_done_ind = ot
   .quick_chart_done_ind,
   reply->get_list[count1].quick_chart_notdone_ind = ot.quick_chart_notdone_ind, reply->get_list[
   count1].retain_time = ot.retain_time, reply->get_list[count1].retain_units = ot.retain_units,
   reply->get_list[count1].overdue_min = ot.overdue_min, reply->get_list[count1].allpositionchart_ind
    = ot.allpositionchart_ind, reply->get_list[count1].cernertask_flag = ot.cernertask_flag,
   reply->get_list[count1].event_cd = ot.event_cd, reply->get_list[count1].reschedule_time = ot
   .reschedule_time, reply->get_list[count1].dcp_forms_ref_id = ot.dcp_forms_ref_id,
   reply->get_list[count1].quick_chart_ind = ot.quick_chart_ind, reply->get_list[count1].
   capture_bill_info_ind = ot.capture_bill_info_ind
  HEAD otp.position_cd
   IF (otp.position_cd != null)
    count2 += 1
    IF (count2 > size(reply->get_list[count1].position_list,5))
     stat = alterlist(reply->get_list[count1].position_list,(count2+ 10))
    ENDIF
    reply->get_list[count1].position_list[count2].position_cd = otp.position_cd
   ENDIF
  DETAIL
   col + 0
  FOOT  otp.position_cd
   col + 0
  FOOT  ot.reference_task_id
   stat = alterlist(reply->get_list[count1].position_list,count2)
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
