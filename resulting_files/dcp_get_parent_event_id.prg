CREATE PROGRAM dcp_get_parent_event_id
 RECORD reply(
   1 event_qual[*]
     2 event_id = f8
     2 parent_event_id = f8
     2 parent_event_class_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp_rec(
   1 temp_list[*]
     2 event_id = f8
     2 parent_event_id = f8
 )
 SET reply->status_data.status = "F"
 SET x = 0
 SET count1 = 0
 SELECT DISTINCT INTO "nl:"
  ce.parent_event_id
  FROM (dummyt tempd  WITH seq = value(size(request->event_id_list,5))),
   clinical_event ce
  PLAN (tempd)
   JOIN (ce
   WHERE (ce.event_id=request->event_id_list[tempd.seq].event_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->event_qual,5))
    stat = alterlist(temp_rec->temp_list,(count1+ 10))
   ENDIF
   temp_rec->temp_list[count1].event_id = ce.event_id, temp_rec->temp_list[count1].parent_event_id =
   ce.parent_event_id
  FOOT REPORT
   stat = alterlist(temp_rec->temp_list,count1)
  WITH check
 ;end select
 SET count2 = 0
 SELECT DISTINCT INTO "nl:"
  ce.event_id, ce.parent_event_id, ce.event_class_cd
  FROM (dummyt d  WITH seq = value(size(temp_rec->temp_list,5))),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.event_id=temp_rec->temp_list[d.seq].parent_event_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   count2 = (count2+ 1)
   IF (count2 > size(reply->event_qual,5))
    stat = alterlist(reply->event_qual,(count2+ 10))
   ENDIF
   reply->event_qual[count2].event_id = temp_rec->temp_list[d.seq].event_id, reply->event_qual[count2
   ].parent_event_id = ce.event_id, reply->event_qual[count2].parent_event_class_cd = ce
   .event_class_cd
  FOOT REPORT
   stat = alterlist(reply->event_qual,count2)
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
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLINICAL_EVENT"
 ENDIF
 CALL echo(build("COUNT1 = ",count1))
 CALL echo(build("COUNT2 = ",count2))
 FOR (x = 1 TO count2)
   CALL echo(build("event_id: ",reply->event_qual[x].event_id))
   CALL echo(build("parent_event_id:",reply->event_qual[x].parent_event_id))
   CALL echo(build("parent_event_class_cd:",reply->event_qual[x].parent_event_class_cd))
 ENDFOR
END GO
