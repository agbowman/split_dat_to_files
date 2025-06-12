CREATE PROGRAM ce_get_modifier_long_text_all:dba
 DECLARE record_status_deleted = f8 WITH noconstant(0.0)
 DECLARE eventcnt = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 SET ntotal2 = value(size(request->event_list,5))
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->event_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->event_list[idx].event_id = request->event_list[ntotal2].event_id
 ENDFOR
 SELECT INTO "nl:"
  ce.event_id
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   clinical_event ce,
   long_text lt
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (ce
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ce.event_id,request->event_list[idx].event_id))
   JOIN (lt
   WHERE lt.long_text_id=ce.modifier_long_text_id)
  DETAIL
   eventcnt += 1
   IF (mod(eventcnt,10)=1)
    stat = alterlist(reply->reply_list,(eventcnt+ 9))
   ENDIF
   reply->reply_list[eventcnt].event_id = ce.event_id, reply->reply_list[eventcnt].valid_from_dt_tm
    = ce.valid_from_dt_tm, reply->reply_list[eventcnt].modifier_long_text_id = ce
   .modifier_long_text_id,
   reply->reply_list[eventcnt].modifier_long_text = lt.long_text
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->reply_list,eventcnt)
 SET reply->qual = eventcnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
