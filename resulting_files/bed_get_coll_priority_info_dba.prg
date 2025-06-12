CREATE PROGRAM bed_get_coll_priority_info:dba
 FREE SET reply
 RECORD reply(
   1 collection_priorities[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 mean = vc
     2 report_priority
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 default_start_time = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SELECT INTO "NL:"
  FROM code_value cv1,
   collection_priority cp,
   code_value cv2
  PLAN (cv1
   WHERE cv1.code_set=2054
    AND cv1.active_ind=1)
   JOIN (cp
   WHERE cp.collection_priority_cd=cv1.code_value)
   JOIN (cv2
   WHERE cv2.code_value=cp.default_report_priority_cd
    AND cv2.active_ind=1)
  ORDER BY cv1.display
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(reply->collection_priorities,ccnt), reply->
   collection_priorities[ccnt].code_value = cv1.code_value,
   reply->collection_priorities[ccnt].display = cv1.display, reply->collection_priorities[ccnt].
   description = cv1.description, reply->collection_priorities[ccnt].mean = cv1.cdf_meaning,
   reply->collection_priorities[ccnt].report_priority.code_value = cv2.code_value, reply->
   collection_priorities[ccnt].report_priority.display = cv2.display, reply->collection_priorities[
   ccnt].report_priority.mean = cv2.cdf_meaning,
   reply->collection_priorities[ccnt].default_start_time = cp.default_start_dt_tm
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
