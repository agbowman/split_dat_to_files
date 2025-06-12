CREATE PROGRAM dcp_get_details_for_task:dba
 RECORD reply(
   1 tasks[*]
     2 task_id = f8
     2 provider_id = f8
     2 result_set_id = f8
     2 order_id = f8
     2 ordered_orig_dt_tm = dq8
     2 orig_order_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD seqrequest(
   1 sequence_name = vc
 )
 RECORD seqreply(
   1 sequence_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant("F")
 SET reply->status_data.status = "F"
 DECLARE task_cnt = i4 WITH protect, constant(size(request->tasks,5))
 IF (task_cnt=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 DECLARE comp_idx = i4 WITH protect, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH public, constant(40)
 DECLARE expand_blocks = i4 WITH protect, constant(ceil((task_cnt/ (1.0 * expand_size))))
 DECLARE total_items = i4 WITH protect, constant((expand_blocks * expand_size))
 SET stat = alterlist(request->tasks,total_items)
 SET stat = alterlist(reply->tasks,task_cnt)
 FOR (comp_idx = (task_cnt+ 1) TO total_items)
   SET request->tasks[comp_idx].task_id = request->tasks[task_cnt].task_id
   SET request->tasks[comp_idx].order_id = request->tasks[task_cnt].order_id
   SET request->tasks[comp_idx].action_seq = request->tasks[task_cnt].action_seq
 ENDFOR
 FOR (i = 1 TO task_cnt)
  SET reply->tasks[i].task_id = request->tasks[i].task_id
  SET reply->tasks[i].order_id = request->tasks[i].order_id
 ENDFOR
 SELECT INTO "nl:"
  oa.provider_id
  FROM (dummyt d  WITH seq = value(expand_blocks)),
   order_action oa,
   orders o
  PLAN (d
   WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
   JOIN (oa
   WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),oa.order_id,request->tasks[
    expand_idx].order_id,
    oa.action_sequence,request->tasks[expand_idx].action_seq))
   JOIN (o
   WHERE o.order_id=oa.order_id)
  ORDER BY oa.order_id
  HEAD oa.order_id
   startcnt = 1
   FOR (x = 1 TO task_cnt)
     IF ((reply->tasks[x].order_id=oa.order_id))
      reply->tasks[x].provider_id = oa.action_personnel_id, reply->tasks[x].ordered_orig_dt_tm = o
      .orig_order_dt_tm, reply->tasks[x].orig_order_tz = o.orig_order_tz,
      reply->tasks[x].result_set_id = 0
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ta.task_id, ta.result_set_id
  FROM (dummyt d  WITH seq = value(expand_blocks)),
   task_activity ta
  PLAN (d
   WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
   JOIN (ta
   WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),ta.task_id,request->tasks[
    expand_idx].task_id))
  ORDER BY ta.task_id
  HEAD ta.task_id
   startcnt = 1
   FOR (x = 1 TO task_cnt)
     IF ((reply->tasks[x].task_id=ta.task_id))
      reply->tasks[x].result_set_id = ta.result_set_id
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SET seqrequest->sequence_name = "result_set_seq"
 FOR (i = 1 TO task_cnt)
   IF ((reply->tasks[i].result_set_id=0))
    EXECUTE dcp_get_next_avail_seq  WITH replace("REQUEST","SEQREQUEST"), replace("REPLY","SEQREPLY")
    IF ((seqreply->status_data.status="F"))
     SET failed = "T"
     GO TO exit_script
    ENDIF
    SET reply->tasks[i].result_set_id = seqreply->sequence_id
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO TASKS SELECTED"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD seqrequest
 FREE RECORD seqreply
END GO
