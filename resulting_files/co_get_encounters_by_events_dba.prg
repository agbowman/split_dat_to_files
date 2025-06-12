CREATE PROGRAM co_get_encounters_by_events:dba
 RECORD reply(
   1 encounters[*]
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo(build("event_cd=",request->event_cd))
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.updt_dt_tm >= cnvtdatetime(request->beg_dt_tm)
    AND ((ce.event_cd+ 0)=request->event_cd)
    AND ((ce.event_end_dt_tm+ 0) >= cnvtdatetime(request->beg_dt_tm))
    AND ((ce.event_end_dt_tm+ 0) < cnvtdatetime(request->end_dt_tm))
    AND ((ce.valid_until_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
    AND ((ce.view_level+ 0)=1)
    AND ((ce.publish_flag+ 0)=1)
    AND ce.event_cd > 0)
  ORDER BY ce.encntr_id
  HEAD REPORT
   pat_count = 0
  HEAD ce.encntr_id
   pat_count = (pat_count+ 1)
   IF (mod(pat_count,50)=1)
    stat = alterlist(reply->encounters,(pat_count+ 49))
   ENDIF
   reply->encounters[pat_count].encntr_id = ce.encntr_id
  DETAIL
   junk = 1
  FOOT REPORT
   stat = alterlist(reply->encounters,pat_count)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
