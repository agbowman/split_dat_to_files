CREATE PROGRAM cv_utl_sync_person_id:dba
 RECORD internal(
   1 event[*]
     2 event_id = f8
     2 person_id = f8
     2 old_person_id = f8
 )
 SET cnt = 0
 SELECT INTO "NL:"
  *
  FROM cv_registry_event cre,
   clinical_event ce
  PLAN (cre)
   JOIN (ce
   WHERE cre.event_id=ce.event_id
    AND cre.person_id != ce.person_id)
  ORDER BY ce.event_id, ce.person_id
  HEAD ce.event_id
   cnt = (cnt+ 1), stat = alterlist(internal->event,cnt), internal->event[cnt].event_id = ce.event_id,
   internal->event[cnt].person_id = ce.person_id, internal->event[cnt].old_person_id = cre.person_id
  DETAIL
   col 0
  WITH nocounter
 ;end select
 SELECT
  internal->event[cnt].event_id, internal->event[cnt].person_id, internal->event[cnt].old_person_id
  FROM (dummyt d  WITH seq = value(size(internal->event,5)))
  WITH nocounter
 ;end select
 UPDATE  FROM (dummyt d  WITH seq = value(size(internal->event,5))),
   ce_event_reg cre
  SET cre.person_id = internal->event[d.seq].person_id
  PLAN (d)
   JOIN (cre
   WHERE (internal->event[cnt].event_id=internal->event[d.seq].event_id))
  WITH nocounter
 ;end update
 COMMIT
END GO
