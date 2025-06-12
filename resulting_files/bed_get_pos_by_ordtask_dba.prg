CREATE PROGRAM bed_get_pos_by_ordtask:dba
 FREE SET reply
 RECORD reply(
   1 order_tasks[*]
     2 reference_task_id = f8
     2 all_pos_ind = i2
     2 positions[*]
       3 code_value = f8
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = 0
 SET req_cnt = size(request->order_tasks,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->order_tasks,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->order_tasks[x].reference_task_id = request->order_tasks[x].reference_task_id
 ENDFOR
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   order_task o,
   order_task_position_xref ot,
   code_value c
  PLAN (d)
   JOIN (o
   WHERE (o.reference_task_id=reply->order_tasks[d.seq].reference_task_id))
   JOIN (ot
   WHERE ot.reference_task_id=outerjoin(o.reference_task_id))
   JOIN (c
   WHERE c.code_value=outerjoin(ot.position_cd))
  ORDER BY d.seq, c.code_value
  HEAD d.seq
   reply->order_tasks[d.seq].all_pos_ind = o.allpositionchart_ind, tcnt = 0, cnt = 0,
   stat = alterlist(reply->order_tasks[d.seq].positions,100)
  HEAD c.code_value
   IF (c.code_value > 0)
    tcnt = (tcnt+ 1), cnt = (cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->order_tasks[d.seq].positions,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->order_tasks[d.seq].positions[tcnt].code_value = c.code_value, reply->order_tasks[d.seq].
    positions[tcnt].display = c.display
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->order_tasks[d.seq].positions,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
