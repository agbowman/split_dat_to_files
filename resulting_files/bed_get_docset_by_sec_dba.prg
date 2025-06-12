CREATE PROGRAM bed_get_docset_by_sec:dba
 FREE SET reply
 RECORD reply(
   1 sections[*]
     2 doc_set_section_ref_id = f8
     2 doc_sets[*]
       3 doc_set_ref_id = f8
       3 name = vc
       3 description = vc
       3 order_tasks[*]
         4 reference_task_id = f8
         4 description = vc
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
 SET req_cnt = size(request->sections,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->sections,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->sections[x].doc_set_section_ref_id = request->sections[x].doc_set_section_ref_id
 ENDFOR
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   doc_set_section_ref_r d2,
   doc_set_ref d3
  PLAN (d)
   JOIN (d2
   WHERE (d2.doc_set_section_ref_id=reply->sections[d.seq].doc_set_section_ref_id)
    AND d2.active_ind=1
    AND d2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d3
   WHERE d3.doc_set_ref_id=d2.doc_set_ref_id
    AND d3.active_ind=1
    AND d3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, d3.doc_set_ref_id
  HEAD d.seq
   cnt = 0, tcnt = 0, stat = alterlist(reply->sections[d.seq].doc_sets,100)
  HEAD d3.doc_set_ref_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->sections[d.seq].doc_sets,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->sections[d.seq].doc_sets[tcnt].doc_set_ref_id = d3.doc_set_ref_id, reply->sections[d.seq].
   doc_sets[tcnt].name = d3.doc_set_name, reply->sections[d.seq].doc_sets[tcnt].description = d3
   .doc_set_description
  FOOT  d.seq
   stat = alterlist(reply->sections[d.seq].doc_sets,tcnt)
  WITH nocounter
 ;end select
 FOR (t = 1 TO req_cnt)
  SET dcnt = size(reply->sections[t].doc_sets,5)
  IF (dcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dcnt)),
     task_charting_agent_r r,
     order_task o
    PLAN (d)
     JOIN (r
     WHERE (r.charting_agent_entity_id=reply->sections[t].doc_sets[d.seq].doc_set_ref_id)
      AND r.charting_agent_entity_name="DOC_SET_REF")
     JOIN (o
     WHERE o.reference_task_id=r.reference_task_id
      AND o.active_ind=1
      AND o.dcp_forms_ref_id > 0
      AND o.quick_chart_done_ind IN (0, null)
      AND o.quick_chart_ind IN (0, null))
    ORDER BY d.seq, o.reference_task_id
    HEAD d.seq
     ocnt = 0, cnt = 0, stat = alterlist(reply->sections[t].doc_sets[d.seq].order_tasks,100)
    HEAD o.reference_task_id
     ocnt = (ocnt+ 1), cnt = (cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(reply->sections[t].doc_sets[d.seq].order_tasks,(ocnt+ 100)), cnt = 1
     ENDIF
     reply->sections[t].doc_sets[d.seq].order_tasks[ocnt].reference_task_id = o.reference_task_id,
     reply->sections[t].doc_sets[d.seq].order_tasks[ocnt].description = o.task_description
    FOOT  d.seq
     stat = alterlist(reply->sections[t].doc_sets[d.seq].order_tasks,ocnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
