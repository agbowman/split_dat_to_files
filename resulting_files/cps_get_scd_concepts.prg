CREATE PROGRAM cps_get_scd_concepts
 RECORD reply(
   1 event_list[*]
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET replies = 0
 SET eventcnt = size(request->event_list,5)
 SET phrasecnt = size(request->phrase_list,5)
 SELECT INTO "NL:"
  s.event_id, ph.phrase_string, ph_exists = decode(ph.seq,"Y","N")
  FROM scd_story s,
   scd_term t,
   scr_phrase ph,
   (dummyt dt  WITH seq = value(eventcnt)),
   (dummyt dt2  WITH seq = value(phrasecnt))
  PLAN (dt)
   JOIN (s
   WHERE (s.event_id=request->event_list[dt.seq].event_id))
   JOIN (t
   WHERE t.scd_story_id=s.scd_story_id)
   JOIN (dt2)
   JOIN (ph
   WHERE ph.scr_phrase_id=t.scr_phrase_id
    AND (ph.phrase_string=request->phrase_list[dt2.seq].phrase))
  ORDER BY s.event_id
  HEAD s.event_id
   IF (ph_exists="Y")
    replies = (replies+ 1)
    IF (replies > size(reply->event_list,5))
     stat = alterlist(reply->event_list,replies)
    ENDIF
    reply->event_list[replies].event_id = s.event_id
   ENDIF
  WITH outerjoin = dt, dt2
 ;end select
 IF (replies=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
