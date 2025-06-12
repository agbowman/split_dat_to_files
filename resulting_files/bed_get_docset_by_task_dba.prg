CREATE PROGRAM bed_get_docset_by_task:dba
 FREE SET reply
 RECORD reply(
   1 order_tasks[*]
     2 reference_task_id = f8
     2 doc_sets[*]
       3 doc_set_ref_id = f8
       3 name = vc
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
   task_charting_agent_r r,
   doc_set_ref s
  PLAN (d)
   JOIN (r
   WHERE (r.reference_task_id=reply->order_tasks[d.seq].reference_task_id)
    AND r.charting_agent_entity_name="DOC_SET_REF")
   JOIN (s
   WHERE s.doc_set_ref_id=r.charting_agent_entity_id
    AND s.active_ind=1
    AND s.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND s.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, s.doc_set_ref_id
  HEAD d.seq
   tcnt = 0, cnt = 0, stat = alterlist(reply->order_tasks[d.seq].doc_sets,100)
  HEAD s.doc_set_ref_id
   tcnt = (tcnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->order_tasks[d.seq].doc_sets,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->order_tasks[d.seq].doc_sets[tcnt].doc_set_ref_id = s.doc_set_ref_id, reply->order_tasks[d
   .seq].doc_sets[tcnt].name = s.doc_set_name, reply->order_tasks[d.seq].doc_sets[tcnt].description
    = s.doc_set_description
  FOOT  d.seq
   stat = alterlist(reply->order_tasks[d.seq].doc_sets,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
