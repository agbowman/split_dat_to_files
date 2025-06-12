CREATE PROGRAM dcp_ensure_prefetch:dba
 RECORD event(
   1 qual[*]
     2 accession_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 task_type_cd = f8
     2 task_status_cd = f8
     2 event_id = f8
     2 event_class_cd = f8
     2 task_activity_cd = f8
     2 reference_task_id = f8
     2 msg_subject = vc
     2 assign_prsnl_id = f8
 )
 SET eks_common->event_repeat_count = size(request->elist,5)
 SET cnt = eks_common->event_repeat_count
 SET stat = alterlist(event->qual,cnt)
 FOR (inx = 1 TO cnt)
  SET event->qual[inx].event_id = request->elist[inx].event_id
  SELECT INTO "nl:"
   ce.person_id, ce.order_id, ce.encntr_id
   FROM clinical_event ce
   WHERE (ce.event_id=event->qual[inx].event_id)
   DETAIL
    event->qual[inx].person_id = ce.person_id, event->qual[inx].order_id = ce.order_id, event->qual[
    inx].encntr_id = ce.encntr_id
   WITH nocounter
  ;end select
 ENDFOR
END GO
