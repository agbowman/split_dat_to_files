CREATE PROGRAM aps_get_event_codes:dba
 SELECT INTO "nl:"
  cv.event_cd, d.seq
  FROM code_value_event_r cv,
   (dummyt d  WITH seq = value(size(event->qual,5)))
  PLAN (d)
   JOIN (cv
   WHERE (event->qual[d.seq].parent_cd=cv.parent_cd))
  DETAIL
   event->qual[d.seq].event_cd = cv.event_cd
  WITH nocounter
 ;end select
END GO
