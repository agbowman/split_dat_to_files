CREATE PROGRAM dcp_get_event_set_parent:dba
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 event_set_cd = f8
     2 event_set_cd_disp = vc
     2 parent_event_set_cd = f8
     2 parent_event_set_cd_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->event_code_list,5))
 SET x = 0
 SELECT INTO "nl:"
  e.event_cd, es.event_set_cd, es.event_set_cd_disp,
  esc.parent_event_set_cd, cv.display
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   v500_event_code e,
   v500_event_set_code es,
   v500_event_set_canon esc,
   code_value cv
  PLAN (d)
   JOIN (e
   WHERE (e.event_cd=request->event_code_list[d.seq].event_cd))
   JOIN (es
   WHERE cnvtupper(es.event_set_name)=cnvtupper(e.event_set_name))
   JOIN (esc
   WHERE es.event_set_cd=esc.event_set_cd)
   JOIN (cv
   WHERE esc.parent_event_set_cd=cv.code_value)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].event_cd = e.event_cd, reply->qual[count1].event_set_cd = es.event_set_cd,
   reply->qual[count1].event_set_cd_disp = es.event_set_cd_disp,
   reply->qual[count1].parent_event_set_cd_disp = cv.display, reply->qual[count1].parent_event_set_cd
    = esc.parent_event_set_cd
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "V500_EVENT_CODE"
 ENDIF
 CALL echo(build("COUNT! = ",count1))
 FOR (x = 1 TO count1)
   CALL echo(build("event_cd:",reply->qual[x].event_cd))
   CALL echo(build("parent_event_set_cd:",reply->qual[x].parent_event_set_cd))
   CALL echo(build("parent_event_set_cd_disp:",reply->qual[x].parent_event_set_cd_disp))
 ENDFOR
END GO
