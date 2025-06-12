CREATE PROGRAM act_get_ce_history:dba
 RECORD reply(
   1 events[*]
     2 event_id = f8
     2 instances[*]
       3 clinical_event_id = f8
       3 valid_until_dt_tm = dq8
       3 valid_from_dt_tm = dq8
       3 clinsig_updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET event_ids_cnt = size(request->event_ids,5)
 IF (event_ids_cnt <= 0)
  GO TO exit_script
 ENDIF
 SET published_instances_only_ind = request->published_instances_only_ind
 SELECT INTO "nl:"
  ce.valid_from_dt_tm, ce.valid_until_dt_tm, ce.clinical_event_id,
  ce.event_id, ce.clinsig_updt_dt_tm, ce.publish_flag
  FROM (dummyt d  WITH seq = value(event_ids_cnt)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.event_id=request->event_ids[d.seq].event_id))
  ORDER BY ce.valid_from_dt_tm DESC
  HEAD REPORT
   event_cnt = 0
  HEAD ce.event_id
   count = 0, event_cnt = (event_cnt+ 1), stat = alterlist(reply->events,event_cnt),
   reply->events[event_cnt].event_id = ce.event_id
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->events[event_cnt].instances,5))
    stat = alterlist(reply->events[event_cnt].instances,(count+ 5))
   ENDIF
   IF (((published_instances_only_ind=0) OR (ce.publish_flag=1)) )
    reply->events[event_cnt].instances[count].clinical_event_id = ce.clinical_event_id, reply->
    events[event_cnt].instances[count].valid_from_dt_tm = ce.valid_from_dt_tm, reply->events[
    event_cnt].instances[count].valid_until_dt_tm = ce.valid_until_dt_tm,
    reply->events[event_cnt].instances[count].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->events[event_cnt].instances,count)
  WITH nocounter
 ;end select
#exit_script
 SET replysize = size(reply->events,5)
 CALL echo(build("Size:  ",cnvtstring(replysize)))
 IF (replysize > 0)
  IF (replysize=event_ids_cnt)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
