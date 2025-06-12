CREATE PROGRAM ce_retrieve_root_client_ident:dba
 DECLARE root_client_ident = c100
 SET continue_ind = true
 SET previous_event = request->start_event_id
 SET current_event = request->start_event_id
 SET dcnt = 0
 SET root_exists = false
 WHILE (continue_ind=true)
  SELECT INTO "nl:"
   ce.parent_event_id, ceu.client_ident
   FROM clinical_event ce,
    ce_uuid ceu
   WHERE ce.event_id=current_event
    AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
    AND ceu.event_id=ce.event_id
   HEAD REPORT
    dcnt = 0
   DETAIL
    dcnt += 1
    IF (ce.parent_event_id > 0
     AND ce.parent_event_id != ce.event_id)
     previous_event = current_event, current_event = ce.parent_event_id
    ELSE
     root_client_ident = ceu.client_ident, root_exists = true, continue_ind = false
    ENDIF
   FOOT REPORT
    IF (dcnt=0)
     continue_ind = false
    ENDIF
   WITH nullreport
  ;end select
  SELECT INTO "nl:"
   lr.linked_event_id
   FROM ce_linked_result lr,
    clinical_event ce
   WHERE lr.event_id=current_event
    AND lr.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
    AND ce.event_id=lr.linked_event_id
    AND (lr.linked_event_id=(- (1) * ce.parent_event_id))
   DETAIL
    previous_event = current_event, current_event = lr.linked_event_id, continue_ind = true
    IF (previous_event=current_event)
     continue_ind = false
    ENDIF
  ;end select
 ENDWHILE
 SET reply->root_client_ident = root_client_ident
 SET reply->root_exists = root_exists
END GO
