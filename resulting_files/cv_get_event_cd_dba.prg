CREATE PROGRAM cv_get_event_cd:dba
 RECORD reply(
   1 return_rec[*]
     2 alias = vc
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET return_rec_cnt = 0
 SET code_value = 0
 SET code_set = 72
 SET failed = "F"
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  cv.code_value, cv.alias
  FROM code_value_alias cv,
   (dummyt t  WITH seq = value(size(request->get_rec,5)))
  PLAN (t)
   JOIN (cv
   WHERE (cv.alias=request->get_rec[t.seq].alias)
    AND cv.code_set=72)
  HEAD REPORT
   return_rec_cnt = 0, stat = alterlist(reply->return_rec,10)
  DETAIL
   failed = "T", return_rec_cnt = (return_rec_cnt+ 1)
   IF (mod(return_rec_cnt,10)=1
    AND return_rec_cnt != 1)
    stat = alterlist(reply->return_rec,(return_rec_cnt+ 10))
   ENDIF
   reply->return_rec[return_rec_cnt].code_value = cv.code_value, reply->return_rec[return_rec_cnt].
   alias = cv.alias
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->return_rec,return_rec_cnt)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "get_event_cd_from_ALIAS"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_GET_EVENT_cd"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
