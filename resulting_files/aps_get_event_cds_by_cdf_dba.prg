CREATE PROGRAM aps_get_event_cds_by_cdf:dba
 RECORD reply(
   1 qual[*]
     2 code_set = i4
     2 cdf_meaning = c12
     2 event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD event(
   1 qual[*]
     2 code_set = i4
     2 cdf_meaning = c12
     2 parent_cd = f8
     2 event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 DECLARE event_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "S"
 SET request_cnt = cnvtint(size(request->qual,5))
 SET event_index = 0
 SET reply_cnt = 0
 SELECT INTO "nl:"
  cv.code_value, d.seq
  FROM code_value cv,
   (dummyt d  WITH seq = value(request_cnt))
  PLAN (d)
   JOIN (cv
   WHERE (request->qual[d.seq].code_set=cv.code_set)
    AND (request->qual[d.seq].cdf_meaning=cv.cdf_meaning))
  HEAD REPORT
   stat = alterlist(event->qual,request_cnt)
  DETAIL
   event_cnt = (event_cnt+ 1), event->qual[d.seq].code_set = request->qual[d.seq].code_set, event->
   qual[d.seq].cdf_meaning = request->qual[d.seq].cdf_meaning,
   event->qual[d.seq].parent_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (event_cnt != request_cnt)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  EXECUTE aps_get_event_codes
  FOR (event_index = 1 TO request_cnt)
    IF ((event->qual[event_index].event_cd > 0))
     SET reply_cnt = (reply_cnt+ 1)
     SET stat = alterlist(reply->qual,reply_cnt)
     SET reply->qual[reply_cnt].code_set = event->qual[event_index].code_set
     SET reply->qual[reply_cnt].cdf_meaning = event->qual[event_index].cdf_meaning
     SET reply->qual[reply_cnt].event_cd = event->qual[event_index].event_cd
    ELSE
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(event->qual[event_index].
      parent_cd,32,2)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE_EVENT_R"
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
#exit_script
END GO
