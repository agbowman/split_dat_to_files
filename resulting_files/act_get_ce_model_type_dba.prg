CREATE PROGRAM act_get_ce_model_type:dba
 RECORD reply(
   1 events[*]
     2 event_id = f8
     2 event_class_cd = f8
     2 event_cd = f8
     2 result_status_cd = f8
     2 view_level = i4
     2 parent_event_id = f8
     2 ce_med_result[*]
       3 iv_event_cd = f8
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
 DECLARE current = q8 WITH public
 SET current = cnvtdatetime(curdate,curtime2)
 CALL echo(build("Current Date/Time: ",format(cnvtdatetime(current),";;Q")))
 SET previouseventid = 0
 SET stat = alterlist(reply->events,event_ids_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(event_ids_cnt)),
   clinical_event ce,
   ce_med_result cmr
  PLAN (d)
   JOIN (ce
   WHERE (ce.event_id=request->event_ids[d.seq].event_id)
    AND ce.valid_until_dt_tm >= cnvtdatetime(current)
    AND ce.valid_from_dt_tm <= cnvtdatetime(current))
   JOIN (cmr
   WHERE outerjoin(ce.event_id)=cmr.event_id)
  ORDER BY ce.event_id, cmr.valid_from_dt_tm DESC
  HEAD REPORT
   count = 0
  DETAIL
   IF (previouseventid != ce.event_id)
    count = (count+ 1), stat = alterlist(reply->events[count].ce_med_result,1), reply->events[count].
    event_id = ce.event_id,
    reply->events[count].parent_event_id = ce.parent_event_id, reply->events[count].event_class_cd =
    ce.event_class_cd, reply->events[count].event_cd = ce.event_cd,
    reply->events[count].result_status_cd = ce.result_status_cd, reply->events[count].view_level = ce
    .view_level, reply->events[count].ce_med_result[1].iv_event_cd = cmr.iv_event_cd
   ENDIF
   previouseventid = ce.event_id,
   CALL echo(build("EventID:  ",cnvtstring(previouseventid))),
   CALL echo(build("iv event:  ",cnvtstring(cmr.iv_event_cd))),
   CALL echo(build("iv event:  ",format(cmr.valid_from_dt_tm,";;Q")))
  WITH nocounter
 ;end select
#exit_script
 SET replysize = size(reply->events,5)
 CALL echorecord(reply,"cer_temp:temp.dat")
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
