CREATE PROGRAM dcp_get_tasksel_list:dba
 RECORD reply(
   1 qual_cnt = i4
   1 qual[10]
     2 display = vc
     2 code = f8
     2 keyval = vc
     2 event_cd = f8
     2 type = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET s_cnt = 0
 SET show_inactive_ind = request->show_inactive_ind
 IF (show_inactive_ind=0)
  SELECT INTO "NL:"
   ot.reference_task_id
   FROM order_task ot,
    form_association fat
   PLAN (ot
    WHERE (ot.task_description_key >= request->seed)
     AND ot.active_ind=1)
    JOIN (fat
    WHERE ot.reference_task_id=fat.reference_task_id)
   ORDER BY ot.task_description_key
   HEAD REPORT
    s_cnt = 0
   DETAIL
    s_cnt = (s_cnt+ 1)
    IF (mod(s_cnt,10)=1
     AND s_cnt != 1)
     stat = alter(reply->qual,(s_cnt+ 9))
    ENDIF
    reply->qual[s_cnt].display = ot.task_description, reply->qual[s_cnt].keyval = ot
    .task_description_key, reply->qual[s_cnt].code = ot.reference_task_id,
    reply->qual[s_cnt].event_cd = ot.event_cd
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   ot.task_description
   FROM order_task ot,
    form_assoc fat
   PLAN (ot
    WHERE (ot.task_description_key >= request->seed))
    JOIN (fat
    WHERE ot.reference_task_id=fat.reference_task_id)
   ORDER BY ot.task_description_key
   HEAD REPORT
    s_cnt = 0
   DETAIL
    s_cnt = (s_cnt+ 1)
    IF (mod(s_cnt,10)=1
     AND s_cnt != 1)
     stat = alter(reply->qual,(s_cnt+ 9))
    ENDIF
    reply->qual[s_cnt].display = ot.task_description, reply->qual[s_cnt].keyval = ot
    .task_description_key, reply->qual[s_cnt].code = ot.reference_task_id,
    reply->qual[s_cnt].event_cd = ot.event_cd
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_TASK"
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->qual_cnt = s_cnt
END GO
