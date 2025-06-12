CREATE PROGRAM cps_get_ref_tasks:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET count1 = 0
 SET count2 = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ot.reference_task_id, otp.position_cd, check = decode(otp.seq,"otp","z")
  FROM order_task ot,
   (dummyt d  WITH seq = 1),
   order_task_position_xref otp
  PLAN (ot
   WHERE ot.active_ind=1)
   JOIN (d)
   JOIN (otp
   WHERE ot.reference_task_id=otp.reference_task_id)
  ORDER BY ot.reference_task_id, otp.position_cd
  HEAD REPORT
   count1 = 0
  HEAD ot.reference_task_id
   count2 = 0, count1 = (count1+ 1)
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
   .reschedule_time, reply->get_list[count1].dcp_forms_ref_id = ot.dcp_forms_ref_id
  HEAD otp.position_cd
   IF (check="otp")
    count2 = (count2+ 1)
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
  WITH check, outerjoin = d
 ;end select
 IF (curqual=0)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_TASK"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
