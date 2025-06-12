CREATE PROGRAM bed_get_docset_task:dba
 FREE SET reply
 RECORD reply(
   1 doc_sets[*]
     2 doc_set_ref_id = f8
     2 order_tasks[*]
       3 reference_task_id = f8
       3 description = vc
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
 SET req_cnt = size(request->doc_sets,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->doc_sets,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->doc_sets[x].doc_set_ref_id = request->doc_sets[x].doc_set_ref_id
 ENDFOR
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   task_charting_agent_r r,
   order_task o
  PLAN (d)
   JOIN (r
   WHERE (r.charting_agent_entity_id=reply->doc_sets[d.seq].doc_set_ref_id)
    AND r.charting_agent_entity_name="DOC_SET_REF")
   JOIN (o
   WHERE o.reference_task_id=r.reference_task_id
    AND o.active_ind=1
    AND o.quick_chart_done_ind IN (0, null)
    AND o.quick_chart_ind IN (0, null))
  ORDER BY d.seq, o.reference_task_id
  HEAD d.seq
   tcnt = 0, cnt = 0, stat = alterlist(reply->doc_sets[d.seq].order_tasks,100)
  HEAD o.reference_task_id
   tcnt = (tcnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->doc_sets[d.seq].order_tasks,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->doc_sets[d.seq].order_tasks[tcnt].reference_task_id = o.reference_task_id, reply->doc_sets[
   d.seq].order_tasks[tcnt].description = o.task_description
  FOOT  d.seq
   stat = alterlist(reply->doc_sets[d.seq].order_tasks,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
