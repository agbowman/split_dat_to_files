CREATE PROGRAM co_get_events_after_date:dba
 RECORD reply(
   1 events[*]
     2 event_cd = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 result_val = vc
     2 event_id = f8
     2 ce_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE parse_string_builder(p1) = vc
 IF (size(request->event_codes,5) > 0)
  SET event_code_query_string = parse_string_builder("")
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND parser(event_code_query_string)
     AND ce.event_end_dt_tm >= cnvtdatetime(request->event_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.event_cd > 0)
   ORDER BY ce.event_end_dt_tm
   HEAD REPORT
    event_count = 0
   DETAIL
    event_count = (event_count+ 1)
    IF (mod(event_count,50)=1)
     stat = alterlist(reply->events,(event_count+ 49))
    ENDIF
    reply->events[event_count].event_cd = ce.event_cd, reply->events[event_count].beg_dt_tm = ce
    .event_start_dt_tm, reply->events[event_count].end_dt_tm = ce.event_end_dt_tm,
    reply->events[event_count].result_val = ce.event_tag, reply->events[event_count].event_id = ce
    .event_id, reply->events[event_count].ce_event_id = ce.clinical_event_id
   FOOT REPORT
    stat = alterlist(reply->events,event_count)
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 SUBROUTINE parse_string_builder(p1)
   SET parse_string = fillstring(1000," ")
   SET parse_string = "ce.event_cd in ("
   SET listsize = size(request->event_codes,5)
   FOR (x = 1 TO listsize)
     IF ((request->event_codes[x].event_cd > 0))
      IF (x > 1)
       SET parse_string = build(parse_string,",")
      ENDIF
      SET parse_string = build(parse_string,cnvtstring(request->event_codes[x].event_cd),".0")
     ENDIF
   ENDFOR
   SET parse_string = build(parse_string,")")
   CALL echo(parse_string)
   RETURN(parse_string)
 END ;Subroutine
END GO
