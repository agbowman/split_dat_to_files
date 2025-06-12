CREATE PROGRAM bed_get_ordtask_by_pos:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 order_tasks[*]
       3 reference_task_id = f8
       3 description = vc
       3 all_pos_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_all
 RECORD temp_all(
   1 ots[*]
     2 id = f8
     2 desc = vc
     2 all_pos_ind = i2
 )
 SET reply->status_data.status = "F"
 SET req_cnt = 0
 SET req_cnt = size(request->positions,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->positions,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->positions[x].code_value = request->positions[x].code_value
 ENDFOR
 SET ots_cnt = 0
 SELECT INTO "nl:"
  FROM order_task o,
   code_value c
  PLAN (o
   WHERE o.active_ind=1
    AND o.allpositionchart_ind=1
    AND o.cernertask_flag IN (0, null))
   JOIN (c
   WHERE c.code_value=o.task_type_cd
    AND c.active_ind=1)
  ORDER BY o.reference_task_id
  HEAD REPORT
   ots_cnt = 0, cnt = 0, stat = alterlist(temp_all->ots,100)
  HEAD o.reference_task_id
   ots_cnt = (ots_cnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_all->ots,(ots_cnt+ 100)), cnt = 1
   ENDIF
   temp_all->ots[ots_cnt].id = o.reference_task_id, temp_all->ots[ots_cnt].desc = o.task_description,
   temp_all->ots[ots_cnt].all_pos_ind = o.allpositionchart_ind
  FOOT REPORT
   stat = alterlist(temp_all->ots,ots_cnt)
  WITH nocounter
 ;end select
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   order_task o,
   order_task_position_xref ot,
   code_value c
  PLAN (d)
   JOIN (ot
   WHERE (ot.position_cd=reply->positions[d.seq].code_value))
   JOIN (o
   WHERE o.reference_task_id=ot.reference_task_id
    AND o.active_ind=1
    AND o.allpositionchart_ind IN (0, null)
    AND o.cernertask_flag IN (0, null))
   JOIN (c
   WHERE c.code_value=o.task_type_cd
    AND c.active_ind=1)
  ORDER BY d.seq, o.reference_task_id
  HEAD d.seq
   tcnt = 0, cnt = 0, stat = alterlist(reply->positions[d.seq].order_tasks,100)
  HEAD o.reference_task_id
   tcnt = (tcnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->positions[d.seq].order_tasks,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->positions[d.seq].order_tasks[tcnt].reference_task_id = o.reference_task_id, reply->
   positions[d.seq].order_tasks[tcnt].description = o.task_description, reply->positions[d.seq].
   order_tasks[tcnt].all_pos_ind = o.allpositionchart_ind
  FOOT  d.seq
   stat = alterlist(reply->positions[d.seq].order_tasks,tcnt)
  WITH nocounter
 ;end select
 IF (req_cnt > 0)
  FOR (x = 1 TO req_cnt)
    SET rep_cnt = size(reply->positions[x].order_tasks,5)
    SET stat = alterlist(reply->positions[x].order_tasks,(rep_cnt+ ots_cnt))
    FOR (y = 1 TO ots_cnt)
      SET reply->positions[x].order_tasks[(y+ rep_cnt)].description = temp_all->ots[y].desc
      SET reply->positions[x].order_tasks[(y+ rep_cnt)].reference_task_id = temp_all->ots[y].id
      SET reply->positions[x].order_tasks[(y+ rep_cnt)].all_pos_ind = temp_all->ots[y].all_pos_ind
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
