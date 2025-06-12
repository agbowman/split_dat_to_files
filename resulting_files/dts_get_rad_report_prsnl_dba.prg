CREATE PROGRAM dts_get_rad_report_prsnl:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[10]
      2 rad_report_id = f8
      2 report_prsnl_id = f8
      2 prsnl_relation_flag = i2
      2 proxied_for_id = f8
      2 queue_ind = i2
      2 action_dt_tm = dq8
      2 action_tz = i4
      2 report_event_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  rp.report_event_id, rrp.rad_report_id, rrp.report_prsnl_id,
  rrp.prsnl_relation_flag, rrp.proxied_for_id, rrp.queue_ind,
  rrp.action_dt_tm
  FROM rad_report rp,
   rad_report_prsnl rrp
  PLAN (rp
   WHERE (rp.order_id=request->order_id))
   JOIN (rrp
   WHERE rp.rad_report_id=rrp.rad_report_id)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].rad_report_id = rrp.rad_report_id, reply->qual[count1].report_prsnl_id = rrp
   .report_prsnl_id, reply->qual[count1].prsnl_relation_flag = rrp.prsnl_relation_flag,
   reply->qual[count1].proxied_for_id = rrp.proxied_for_id, reply->qual[count1].queue_ind = rrp
   .queue_ind, reply->qual[count1].action_dt_tm = rrp.action_dt_tm,
   reply->qual[count1].action_tz = rrp.action_tz, reply->qual[count1].report_event_id = rp
   .report_event_id
  WITH nocounter
 ;end select
 SET stat = alter(reply->qual,count1)
 IF (curqual >= 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
