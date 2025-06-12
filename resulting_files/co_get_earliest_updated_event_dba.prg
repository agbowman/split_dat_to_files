CREATE PROGRAM co_get_earliest_updated_event:dba
 RECORD reply(
   1 earliest_event_dt_tm = dq8
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
     AND ce.event_end_dt_tm <= cnvtdatetime(request->event_end_dt_tm)
     AND ce.updt_dt_tm >= cnvtdatetime(request->event_updt_dt_tm)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.event_cd > 0)
   ORDER BY ce.event_end_dt_tm
   HEAD REPORT
    event_count = 0, reply->earliest_event_dt_tm = ce.event_end_dt_tm
   DETAIL
    junk = 1
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
