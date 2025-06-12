CREATE PROGRAM dcp_get_task_orderdetail:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 orders[*]
     2 order_id = f8
     2 order_details[*]
       3 oe_field_id = f8
       3 oe_field_value = f8
       3 oe_field_meaning_id = f8
       3 oe_field_display_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp_request
 RECORD temp_request(
   1 orders_list[*]
     2 order_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE num_orders = i4 WITH protect, noconstant(size(request->orders_list,5))
 DECLARE getorderdetailsforgivenorders() = null
 IF (num_orders > 0)
  CALL getorderdetailsforgivenorders(null)
 ELSE
  GO TO exit_script
 ENDIF
 SUBROUTINE getorderdetailsforgivenorders(dummyvar)
   CALL echo("GetOrderDetailsForGivenOrders")
   DECLARE ord_det = i4 WITH protect, noconstant(0)
   DECLARE numdet = i4 WITH protect, noconstant(0)
   DECLARE expand_sizedet = i4 WITH protect, constant(100)
   DECLARE expand_startdet = i4 WITH protect, noconstant(1)
   DECLARE expand_stopdet = i4 WITH protect, noconstant(100)
   DECLARE expand_totaldet = i4 WITH protect, noconstant(0)
   SET expand_totaldet = (ceil((cnvtreal(num_orders)/ expand_sizedet)) * expand_sizedet)
   SET stat = alterlist(temp_request->orders_list,expand_totaldet)
   FOR (idx = 1 TO expand_totaldet)
     IF (idx <= num_orders)
      SET temp_request->orders_list[idx].order_id = request->orders_list[idx].order_id
     ELSE
      SET temp_request->orders_list[idx].order_id = request->orders_list[num_orders].order_id
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((expand_totaldet/ expand_sizedet))),
     order_detail od
    PLAN (d1
     WHERE assign(expand_startdet,evaluate(d1.seq,1,1,(expand_startdet+ expand_sizedet)))
      AND assign(expand_stopdet,(expand_startdet+ (expand_sizedet - 1))))
     JOIN (od
     WHERE expand(numdet,expand_startdet,expand_stopdet,od.order_id,temp_request->orders_list[numdet]
      .order_id))
    ORDER BY od.order_id, od.oe_field_meaning_id, od.action_sequence DESC
    HEAD REPORT
     ord_cnt = 0
    HEAD od.order_id
     ord_det = 0, ord_cnt = (ord_cnt+ 1)
     IF (mod(ord_cnt,10)=1)
      stat = alterlist(reply->orders,(ord_cnt+ 9))
     ENDIF
     reply->orders[ord_cnt].order_id = od.order_id
    HEAD od.oe_field_meaning_id
     ord_det = (ord_det+ 1)
     IF (mod(ord_det,10)=1)
      stat = alterlist(reply->orders[ord_cnt].order_details,(ord_det+ 9))
     ENDIF
     reply->orders[ord_cnt].order_details[ord_det].oe_field_id = od.oe_field_id, reply->orders[
     ord_cnt].order_details[ord_det].oe_field_meaning_id = od.oe_field_meaning_id, reply->orders[
     ord_cnt].order_details[ord_det].oe_field_value = od.oe_field_value,
     reply->orders[ord_cnt].order_details[ord_det].oe_field_display_value = od.oe_field_display_value
    FOOT  od.order_id
     stat = alterlist(reply->orders[ord_cnt].order_details,ord_det)
    FOOT REPORT
     stat = alterlist(reply->orders,ord_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo(build("ERROR: ",error_msg))
  SET reply->status_data.status = "F"
 ELSEIF (size(reply->orders,5)=0)
  CALL echo("***** No orders *******")
  SET reply->status_data.status = "Z"
 ELSE
  CALL echo("**** Success ********")
  SET reply->status_data.status = "S"
 ENDIF
 SET modify = nopredeclare
END GO
