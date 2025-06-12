CREATE PROGRAM bed_get_dta_by_event:dba
 FREE SET reply
 RECORD reply(
   1 events[*]
     2 code_value = f8
     2 assays[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ecnt = 0
 SET acnt = 0
 SET ecnt = size(request->events,5)
 IF (ecnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->events,ecnt)
 FOR (x = 1 TO ecnt)
   SET reply->events[x].code_value = request->events[x].code_value
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ecnt)),
   code_value_event_r r,
   code_value c
  PLAN (d)
   JOIN (r
   WHERE (r.event_cd=reply->events[d.seq].code_value))
   JOIN (c
   WHERE c.code_value=r.parent_cd
    AND c.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   acnt = 0
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(reply->events[d.seq].assays,acnt), reply->events[d.seq].assays[
   acnt].code_value = c.code_value,
   reply->events[d.seq].assays[acnt].display = c.display, reply->events[d.seq].assays[acnt].
   description = c.description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ecnt)),
   discrete_task_assay a,
   code_value c
  PLAN (d
   WHERE size(reply->events[d.seq].assays,5)=0)
   JOIN (a
   WHERE (a.event_cd=reply->events[d.seq].code_value))
   JOIN (c
   WHERE c.code_value=a.task_assay_cd
    AND c.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   acnt = 0
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(reply->events[d.seq].assays,acnt), reply->events[d.seq].assays[
   acnt].code_value = c.code_value,
   reply->events[d.seq].assays[acnt].display = c.display, reply->events[d.seq].assays[acnt].
   description = c.description
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
