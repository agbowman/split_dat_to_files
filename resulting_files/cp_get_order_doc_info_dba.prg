CREATE PROGRAM cp_get_order_doc_info:dba
 RECORD reply(
   1 qual[*]
     2 prsnl_person_id = f8
     2 action_sequence = f8
     2 action_dt_tm = dq8
     2 action_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM order_detail od
  WHERE (od.order_id=request->order_id)
   AND (od.oe_field_meaning=request->oe_field_meaning)
  ORDER BY od.action_sequence DESC, od.detail_sequence
  HEAD REPORT
   lastestseq = 1, count = 0
  HEAD od.action_sequence
   do_nothing = 0
  DETAIL
   IF (lastestseq=1)
    count = (count+ 1)
    IF (mod(count,5)=1)
     stat = alterlist(reply->qual,(count+ 4))
    ENDIF
    reply->qual[count].prsnl_person_id = od.oe_field_value, reply->qual[count].action_sequence = od
    .action_sequence
   ENDIF
  FOOT  od.action_sequence
   IF (lastestseq=1)
    lastestseq = 0, stat = alterlist(reply->qual,count)
   ENDIF
  FOOT REPORT
   do_nothing = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oa.action_dt_tm, oa.action_tz
  FROM order_action oa,
   (dummyt d  WITH seq = value(size(reply->qual,5)))
  PLAN (d)
   JOIN (oa
   WHERE (oa.order_id=request->order_id)
    AND (oa.action_sequence=reply->qual[d.seq].action_sequence))
  HEAD REPORT
   do_nothing = 0
  DETAIL
   reply->qual[d.seq].action_dt_tm = oa.action_dt_tm, reply->qual[d.seq].action_tz = validate(oa
    .action_tz,0)
  WITH nocounter
 ;end select
 IF (size(reply->qual,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
