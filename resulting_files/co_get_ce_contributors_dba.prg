CREATE PROGRAM co_get_ce_contributors:dba
 RECORD reply(
   1 events[*]
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  FROM ce_contributor_link ccl
  WHERE (ccl.event_id=request->event_id)
   AND ccl.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
  HEAD REPORT
   event_count = 0
  DETAIL
   event_count = (event_count+ 1)
   IF (mod(event_count,30)=1)
    stat = alterlist(reply->events,(event_count+ 29))
   ENDIF
   reply->events[event_count].event_id = ccl.contributor_event_id
  FOOT REPORT
   stat = alterlist(reply->events,event_count)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
