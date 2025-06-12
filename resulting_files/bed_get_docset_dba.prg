CREATE PROGRAM bed_get_docset:dba
 FREE SET reply
 RECORD reply(
   1 doc_sets[*]
     2 doc_set_ref_id = f8
     2 name = vc
     2 description = vc
     2 active_ind = i2
     2 order_tasks[*]
       3 reference_task_id = f8
       3 description = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE ds_parse = vc
 IF ((request->search_string > " "))
  IF (cnvtupper(request->search_type_flag)="C")
   SET ds_parse = concat("d.doc_set_name_key = '*",cnvtupper(request->search_string),"*' and ")
  ELSE
   SET ds_parse = concat("d.doc_set_name_key = '",cnvtupper(request->search_string),"*' and ")
  ENDIF
 ENDIF
 IF ((request->inactive_ind=0))
  SET ds_parse = concat(ds_parse," d.active_ind = 1 and ")
 ENDIF
 SET ds_parse = concat(ds_parse," d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) ",
  " and d.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) and d.prev_doc_set_ref_id = d.doc_set_ref_id",
  " and d.doc_set_description > ' '")
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM doc_set_ref d
  PLAN (d
   WHERE parser(ds_parse))
  ORDER BY d.doc_set_ref_id
  HEAD REPORT
   tcnt = 0, cnt = 0, stat = alterlist(reply->doc_sets,100)
  HEAD d.doc_set_ref_id
   tcnt = (tcnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->doc_sets,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->doc_sets[tcnt].doc_set_ref_id = d.doc_set_ref_id, reply->doc_sets[tcnt].name = d
   .doc_set_name, reply->doc_sets[tcnt].description = d.doc_set_description,
   reply->doc_sets[tcnt].active_ind = d.active_ind
  FOOT REPORT
   stat = alterlist(reply->doc_sets,tcnt)
  WITH nocounter
 ;end select
 IF ((tcnt > request->max_reply)
  AND (request->max_reply > 0))
  SET stat = alterlist(reply->doc_sets,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 IF (validate(request->load_tasks_ind))
  IF ((request->load_tasks_ind=1)
   AND tcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt)),
     task_charting_agent_r r,
     order_task o
    PLAN (d)
     JOIN (r
     WHERE (r.charting_agent_entity_id=reply->doc_sets[d.seq].doc_set_ref_id)
      AND r.charting_agent_entity_name="DOC_SET_REF")
     JOIN (o
     WHERE o.reference_task_id=r.reference_task_id
      AND o.active_ind=1
      AND o.dcp_forms_ref_id > 0
      AND o.quick_chart_done_ind IN (0, null)
      AND o.quick_chart_ind IN (0, null))
    ORDER BY d.seq, o.reference_task_id
    HEAD d.seq
     ocnt = 0, cnt = 0, stat = alterlist(reply->doc_sets[d.seq].order_tasks,100)
    HEAD o.reference_task_id
     ocnt = (ocnt+ 1), cnt = (cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(reply->doc_sets[d.seq].order_tasks,(ocnt+ 100)), cnt = 1
     ENDIF
     reply->doc_sets[d.seq].order_tasks[ocnt].reference_task_id = o.reference_task_id, reply->
     doc_sets[d.seq].order_tasks[ocnt].description = o.task_description
    FOOT  d.seq
     stat = alterlist(reply->doc_sets[d.seq].order_tasks,ocnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
