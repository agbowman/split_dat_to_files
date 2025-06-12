CREATE PROGRAM ce_get_order_details:dba
 DECLARE orderidssize = i4 WITH constant(size(request->order_ids,5))
 DECLARE batch_size = i4 WITH constant(20)
 DECLARE paddedlistsize = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 IF (orderidssize)
  SET paddedlistsize = (ceil((cnvtreal(orderidssize)/ batch_size)) * batch_size)
  SET stat = alterlist(request->order_ids,paddedlistsize)
  FOR (idx = (orderidssize+ 1) TO paddedlistsize)
    SET request->order_ids[idx].order_id = request->order_ids[orderidssize].order_id
  ENDFOR
  SET idx = 0
  SET loop_cnt = ceil((cnvtreal(orderidssize)/ batch_size))
 ELSE
  GO TO exit_script
 ENDIF
 SELECT INTO "n1;"
  od.oe_field_id, od.order_id, od.oe_field_value
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   order_detail od,
   (
   (
   (SELECT
    od1.order_id, od1.oe_field_id, od1.oe_field_meaning_id,
    action_sequence = max(od1.action_sequence)
    FROM order_detail od1
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),od1.order_id,request->order_ids[idx].order_id)
     AND (od1.oe_field_meaning_id=request->oe_field_meaning_id)
    GROUP BY od1.order_id, od1.oe_field_id, od1.oe_field_meaning_id
    WITH sqltype("f8","f8","f8","i4"), orahintcbo("INDEX(od XIE2ORDER_DETAIL)")))
   od2)
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (od)
   JOIN (od2
   WHERE od.order_id=od2.order_id
    AND od.oe_field_meaning_id=od2.oe_field_meaning_id
    AND od.oe_field_id=od2.oe_field_id
    AND od.action_sequence=od2.action_sequence
    AND od.oe_field_value != 0)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].oe_field_id = od.oe_field_id, reply->reply_list[cnt].order_id = od.order_id,
   reply->reply_list[cnt].oe_field_value = od.oe_field_value
  FOOT REPORT
   stat = alterlist(reply->reply_list,cnt)
  WITH nocounter, orahintcbo("INDEX(od XIE2ORDER_DETAIL)")
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
#exit_script
END GO
