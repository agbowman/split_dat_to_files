CREATE PROGRAM dcp_get_pip_ord_detail:dba
 RECORD reply(
   1 oe_field_id = f8
   1 oe_field_value = f8
   1 oe_field_meaning = vc
   1 oe_field_meaning_id = f8
   1 oe_field_dt_tm_value = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET r_cnt = 0
 SELECT
  od.order_id
  FROM order_detail od
  WHERE (od.order_id=request->order_id)
   AND (od.oe_field_id=request->oe_field_id)
  ORDER BY od.order_id, od.action_sequence DESC
  HEAD REPORT
   r_cnt = 0
  HEAD od.order_id
   r_cnt = 1, reply->oe_field_id = od.oe_field_id, reply->oe_field_value = od.oe_field_value,
   reply->oe_field_meaning = od.oe_field_meaning, reply->oe_field_meaning_id = od.oe_field_meaning_id,
   reply->oe_field_dt_tm_value = od.oe_field_dt_tm_value
  WITH nocounter
 ;end select
 IF (r_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
