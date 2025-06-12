CREATE PROGRAM earlywarningtest:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD event(
   1 qual[*]
     2 c_event_id = f8
 )
 SET cnt = 0
 SELECT INTO "nl:"
  ce.encntr_id, ce.event_cd, ce.event_end_dt_tm
  FROM bhs_early_warning be,
   clinical_event ce
  PLAN (be
   WHERE be.active_ind=1
    AND be.encntr_id=47204327)
   JOIN (ce
   WHERE ce.encntr_id=47204327
    AND ce.clinical_event_id=ce.clinical_event_id)
  ORDER BY ce.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(event->qual,cnt), event->qual[cnt].c_event_id = ce
   .clinical_event_id
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  ce.encntr_id, br.eventtype, date = format(br.updt_dt_tm,";;q"),
  p.name_full_formatted, event = uar_get_code_display(ce.event_cd), br.total_score,
  br.event_score, ce.result_val, bt.range_type,
  bt.val, bt.lowerrange, bt.upperrange,
  bt.score
  FROM person p,
   bhs_range_system bt,
   bhs_early_warning br,
   clinical_event ce,
   bhs_event_cd_list be,
   (dummyt d  WITH seq = cnt)
  PLAN (d)
   JOIN (br
   WHERE br.active_ind=1
    AND (br.clinical_event_id=event->qual[d.seq].c_event_id))
   JOIN (ce
   WHERE ce.clinical_event_id=br.clinical_event_id)
   JOIN (be
   WHERE be.event_cd=ce.event_cd)
   JOIN (bt
   WHERE bt.parent_entity_id=be.event_cd_list_id)
   JOIN (p
   WHERE p.person_id=ce.person_id)
  ORDER BY ce.encntr_id, br.updt_dt_tm
  WITH format, separator = " "
 ;end select
END GO
