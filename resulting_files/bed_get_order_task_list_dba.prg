CREATE PROGRAM bed_get_order_task_list:dba
 FREE SET reply
 RECORD reply(
   1 order_tasks[*]
     2 reference_task_id = f8
     2 description = vc
     2 all_pos_ind = i2
     2 task_type_code_value = f8
     2 doc_sets[*]
       3 doc_set_ref_id = f8
       3 description = vc
       3 name = vc
     2 related_results_ind = i2
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
 SET related_results_filter_ind = 0
 IF (validate(request->related_results_filter_ind))
  IF ((request->related_results_filter_ind=1))
   SET related_results_filter_ind = 1
  ELSEIF ((request->related_results_filter_ind=2))
   SET related_results_filter_ind = 2
  ENDIF
 ENDIF
 DECLARE ot_parse = vc
 IF ((request->search_string > " "))
  IF (cnvtupper(request->search_type_flag)="C")
   SET ot_parse = concat("o.task_description_key = '*",cnvtupper(request->search_string),"*' and ")
  ELSE
   SET ot_parse = concat("o.task_description_key = '",cnvtupper(request->search_string),"*' and ")
  ENDIF
 ENDIF
 IF ((request->task_type_code_value > 0))
  SET ot_parse = build(ot_parse," o.task_type_cd = ",request->task_type_code_value," and ")
 ENDIF
 IF (validate(request->exclude_cerner_tasks_ind))
  IF ((request->exclude_cerner_tasks_ind=1))
   SET ot_parse = concat(ot_parse," o.cernertask_flag in (0,null) and ")
  ENDIF
 ENDIF
 IF (validate(request->allow_quick_chart_ind))
  IF ((request->allow_quick_chart_ind=1))
   SET ot_parse = concat(ot_parse," o.active_ind = 1 ")
  ELSE
   SET ot_parse = concat(ot_parse,
    " o.active_ind = 1 and o.quick_chart_done_ind in (0,null) and o.quick_chart_ind in (0,null) ")
  ENDIF
 ELSE
  SET ot_parse = concat(ot_parse,
   " o.active_ind = 1 and o.quick_chart_done_ind in (0,null) and o.quick_chart_ind in (0,null) ")
 ENDIF
 SET tcnt = 0
 IF (related_results_filter_ind=0)
  SELECT INTO "nl:"
   FROM order_task o,
    code_value c
   PLAN (o
    WHERE parser(ot_parse))
    JOIN (c
    WHERE c.code_value=o.task_type_cd
     AND c.active_ind=1)
   ORDER BY o.reference_task_id
   HEAD REPORT
    tcnt = 0, cnt = 0, stat = alterlist(reply->order_tasks,100)
   HEAD o.reference_task_id
    tcnt = (tcnt+ 1), cnt = (cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->order_tasks,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->order_tasks[tcnt].reference_task_id = o.reference_task_id, reply->order_tasks[tcnt].
    description = o.task_description, reply->order_tasks[tcnt].all_pos_ind = o.allpositionchart_ind,
    reply->order_tasks[tcnt].task_type_code_value = o.task_type_cd
   FOOT REPORT
    stat = alterlist(reply->order_tasks,tcnt)
   WITH nocounter
  ;end select
 ELSEIF (related_results_filter_ind=1)
  SELECT INTO "nl:"
   FROM order_task o,
    code_value c,
    task_discrete_r t,
    discrete_task_assay dta,
    code_value cv1,
    code_value cv2
   PLAN (o
    WHERE parser(ot_parse))
    JOIN (c
    WHERE c.code_value=o.task_type_cd
     AND c.active_ind=1)
    JOIN (t
    WHERE t.reference_task_id=o.reference_task_id
     AND t.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=t.task_assay_cd
     AND dta.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=dta.default_result_type_cd
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=dta.activity_type_cd
     AND cv2.active_ind=1)
   ORDER BY o.reference_task_id
   HEAD REPORT
    tcnt = 0, cnt = 0, stat = alterlist(reply->order_tasks,100)
   HEAD o.reference_task_id
    tcnt = (tcnt+ 1), cnt = (cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->order_tasks,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->order_tasks[tcnt].reference_task_id = o.reference_task_id, reply->order_tasks[tcnt].
    description = o.task_description, reply->order_tasks[tcnt].all_pos_ind = o.allpositionchart_ind,
    reply->order_tasks[tcnt].task_type_code_value = o.task_type_cd
   FOOT REPORT
    stat = alterlist(reply->order_tasks,tcnt)
   WITH nocounter
  ;end select
 ELSEIF (related_results_filter_ind=2)
  SELECT INTO "nl:"
   FROM order_task o,
    code_value c
   PLAN (o
    WHERE parser(ot_parse))
    JOIN (c
    WHERE c.code_value=o.task_type_cd
     AND c.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     t.reference_task_id
     FROM task_discrete_r t
     WHERE t.reference_task_id=o.reference_task_id
      AND t.active_ind=1))))
   ORDER BY o.reference_task_id
   HEAD REPORT
    tcnt = 0, cnt = 0, stat = alterlist(reply->order_tasks,100)
   HEAD o.reference_task_id
    tcnt = (tcnt+ 1), cnt = (cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->order_tasks,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->order_tasks[tcnt].reference_task_id = o.reference_task_id, reply->order_tasks[tcnt].
    description = o.task_description, reply->order_tasks[tcnt].all_pos_ind = o.allpositionchart_ind,
    reply->order_tasks[tcnt].task_type_code_value = o.task_type_cd
   FOOT REPORT
    stat = alterlist(reply->order_tasks,tcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((tcnt > request->max_reply)
  AND (request->max_reply > 0))
  SET stat = alterlist(reply->order_tasks,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 IF (validate(request->load_doc_set_ind))
  IF ((request->load_doc_set_ind=1))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt)),
     task_charting_agent_r t,
     doc_set_ref s,
     doc_set_ref s2
    PLAN (d)
     JOIN (t
     WHERE (t.reference_task_id=reply->order_tasks[d.seq].reference_task_id)
      AND t.charting_agent_entity_name="DOC_SET_REF")
     JOIN (s
     WHERE s.doc_set_ref_id=t.charting_agent_entity_id)
     JOIN (s2
     WHERE s2.doc_set_ref_id=s.prev_doc_set_ref_id)
    ORDER BY d.seq, s2.doc_set_ref_id
    HEAD d.seq
     ds_cnt = 0, dst_cnt = 0, stat = alterlist(reply->order_tasks[d.seq].doc_sets,10)
    HEAD s2.doc_set_ref_id
     ds_cnt = (ds_cnt+ 1), dst_cnt = (dst_cnt+ 1)
     IF (ds_cnt > 10)
      stat = alterlist(reply->order_tasks[d.seq].doc_sets,(dst_cnt+ 10)), ds_cnt = 1
     ENDIF
     reply->order_tasks[d.seq].doc_sets[dst_cnt].doc_set_ref_id = s2.doc_set_ref_id, reply->
     order_tasks[d.seq].doc_sets[dst_cnt].description = s2.doc_set_description, reply->order_tasks[d
     .seq].doc_sets[dst_cnt].name = s2.doc_set_name
    FOOT  d.seq
     stat = alterlist(reply->order_tasks[d.seq].doc_sets,dst_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (validate(request->load_related_results_ind))
  IF ((request->load_related_results_ind=1))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt)),
     task_discrete_r t,
     discrete_task_assay dta,
     code_value cv1,
     code_value cv2
    PLAN (d)
     JOIN (t
     WHERE (t.reference_task_id=reply->order_tasks[d.seq].reference_task_id)
      AND t.active_ind=1)
     JOIN (dta
     WHERE dta.task_assay_cd=t.task_assay_cd
      AND dta.active_ind=1)
     JOIN (cv1
     WHERE cv1.code_value=dta.default_result_type_cd
      AND cv1.active_ind=1)
     JOIN (cv2
     WHERE cv2.code_value=dta.activity_type_cd
      AND cv2.active_ind=1)
    DETAIL
     reply->order_tasks[d.seq].related_results_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 CALL echo(ot_parse)
END GO
