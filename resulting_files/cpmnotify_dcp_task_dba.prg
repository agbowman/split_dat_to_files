CREATE PROGRAM cpmnotify_dcp_task:dba
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 datalist[*]
       3 task_id = f8
       3 reference_task_id = f8
       3 task_dt_tm = dq8
       3 task_status_cd = f8
       3 task_class_cd = f8
       3 event_id = f8
       3 person_id = f8
       3 encntr_id = f8
       3 task_type_cd = f8
       3 task_activity_cd = f8
       3 med_order_type_cd = f8
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 updt_cnt = i4
       3 reschedule_ind = i2
       3 result_set_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_request(
   1 last_run_dt_tm = dq8
   1 entity_list[*]
     2 entity_id = f8
 )
 SET reply->status_data.status = "F"
 SET num = 0
 SET pos = 0
 SET data_cnt = 0
 SET actual_size = size(request->entity_list,5)
 SET expand_size = 200
 SET expand_total = (ceil((cnvtreal(actual_size)/ expand_size)) * expand_size)
 SET expand_start = 1
 SET expand_stop = 200
 SET reply->run_dt_tm = cnvtdatetime(curdate,curtime3)
 SET stat = alterlist(temp_request->entity_list,expand_total)
 FOR (idx = 1 TO expand_total)
   IF (idx <= actual_size)
    SET temp_request->entity_list[idx].entity_id = request->entity_list[idx].entity_id
   ELSE
    SET temp_request->entity_list[idx].entity_id = request->entity_list[actual_size].entity_id
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  ta.person_id, ta.updt_dt_tm
  FROM task_activity ta,
   (dummyt d  WITH seq = value((expand_total/ expand_size)))
  PLAN (d
   WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
    AND assign(expand_stop,(expand_start+ (expand_size - 1))))
   JOIN (ta
   WHERE expand(num,expand_start,expand_stop,ta.person_id,temp_request->entity_list[num].entity_id)
    AND ta.updt_dt_tm >= cnvtdatetime(request->last_run_dt_tm))
  ORDER BY ta.person_id
  HEAD REPORT
   pos = 0, stat = alterlist(reply->entity_list,actual_size)
  HEAD ta.person_id
   data_cnt = 0, pos = (pos+ 1), reply->entity_list[pos].entity_id = ta.person_id
  DETAIL
   data_cnt = (data_cnt+ 1)
   IF (mod(data_cnt,10)=1)
    stat = alterlist(reply->entity_list[pos].datalist,(data_cnt+ 9))
   ENDIF
   reply->entity_list[pos].datalist[data_cnt].task_id = ta.task_id, reply->entity_list[pos].datalist[
   data_cnt].reference_task_id = ta.reference_task_id, reply->entity_list[pos].datalist[data_cnt].
   task_dt_tm = ta.task_dt_tm,
   reply->entity_list[pos].datalist[data_cnt].task_status_cd = ta.task_status_cd, reply->entity_list[
   pos].datalist[data_cnt].task_class_cd = ta.task_class_cd, reply->entity_list[pos].datalist[
   data_cnt].event_id = ta.event_id,
   reply->entity_list[pos].datalist[data_cnt].person_id = ta.person_id, reply->entity_list[pos].
   datalist[data_cnt].encntr_id = ta.encntr_id, reply->entity_list[pos].datalist[data_cnt].
   task_type_cd = ta.task_type_cd,
   reply->entity_list[pos].datalist[data_cnt].task_activity_cd = ta.task_activity_cd, reply->
   entity_list[pos].datalist[data_cnt].med_order_type_cd = ta.med_order_type_cd, reply->entity_list[
   pos].datalist[data_cnt].updt_id = ta.updt_id,
   reply->entity_list[pos].datalist[data_cnt].updt_dt_tm = cnvtdatetime(ta.updt_dt_tm), reply->
   entity_list[pos].datalist[data_cnt].updt_cnt = ta.updt_cnt, reply->entity_list[pos].datalist[
   data_cnt].reschedule_ind = ta.reschedule_ind,
   reply->entity_list[pos].datalist[data_cnt].result_set_id = ta.result_set_id
  FOOT  ta.person_id
   stat = alterlist(reply->entity_list[pos].datalist,data_cnt)
  FOOT REPORT
   stat = alterlist(reply->entity_list,pos)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
