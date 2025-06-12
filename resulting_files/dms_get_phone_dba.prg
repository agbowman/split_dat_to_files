CREATE PROGRAM dms_get_phone:dba
 RECORD reply(
   1 phone[*]
     2 phone_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 phone_num = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echorecord(request)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.*
  FROM (dummyt d  WITH seq = value(size(request->phone_list,5))),
   phone p
  PLAN (d)
   JOIN (p
   WHERE (p.phone_id=request->phone_list[d.seq].phone_id))
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->phone,(count+ 9))
   ENDIF
   reply->phone[count].phone_id = p.phone_id, reply->phone[count].phone_num = p.phone_num, reply->
   phone[count].parent_entity_name = p.parent_entity_name,
   reply->phone[count].parent_entity_id = p.parent_entity_id
  FOOT REPORT
   stat = alterlist(reply->phone,count)
  WITH nocounter
 ;end select
 IF (size(reply->phone,5) != size(request->phone_list,5))
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "phone"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "error"
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<================ Exiting DMS_GET_PHONE Script =============>")
END GO
