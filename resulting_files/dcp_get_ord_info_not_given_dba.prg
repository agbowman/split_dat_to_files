CREATE PROGRAM dcp_get_ord_info_not_given:dba
 RECORD reply(
   1 orders[*]
     2 order_id = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 action_sequence_list[*]
       3 action_sequence = i4
       3 route_and_form[*]
         4 oe_field_meaning_id = f8
         4 oe_field_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE qual_cnt = i4 WITH constant(cnvtint(size(request->orders,5)))
 DECLARE order_count = i4 WITH noconstant(0)
 DECLARE as_count = i4 WITH noconstant(0)
 DECLARE route_and_form_count = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4
 DECLARE num = i4 WITH noconstant(0)
 SET ntotal2 = size(request->orders,5)
 SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
 SET stat = alterlist(request->orders,ntotal)
 SET nstart = 1
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->orders[idx].order_id = request->orders[ntotal2].order_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   order_action oa,
   order_detail od,
   orders o,
   order_catalog_synonym ocs
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (oa
   WHERE expand(num,nstart,(nstart+ (nsize - 1)),oa.order_id,request->orders[num].order_id,
    oa.action_sequence,request->orders[num].action_sequence))
   JOIN (od
   WHERE od.order_id=oa.order_id
    AND od.oe_field_meaning_id IN (2050, 2014))
   JOIN (o
   WHERE o.order_id=oa.order_id)
   JOIN (ocs
   WHERE ocs.synonym_id=o.synonym_id)
  ORDER BY oa.order_id, oa.action_sequence, od.oe_field_meaning_id
  HEAD REPORT
   order_count = 0
  HEAD oa.order_id
   as_count = 0, order_count = (order_count+ 1)
   IF (mod(order_count,10)=1)
    stat = alterlist(reply->orders,(order_count+ 9))
   ENDIF
   reply->orders[order_count].order_id = o.order_id, reply->orders[order_count].synonym_id = ocs
   .synonym_id, reply->orders[order_count].mnemonic = ocs.mnemonic
  HEAD oa.action_sequence
   route_and_form_count = 0, as_count = (as_count+ 1), stat = alterlist(reply->orders[order_count].
    action_sequence_list,(as_count+ 1)),
   reply->orders[order_count].action_sequence_list[as_count].action_sequence = oa.action_sequence
  HEAD od.oe_field_meaning_id
   route_and_form_count = (route_and_form_count+ 1), stat = alterlist(reply->orders[order_count].
    action_sequence_list[as_count].route_and_form,(route_and_form_count+ 9)), reply->orders[
   order_count].action_sequence_list[as_count].route_and_form[route_and_form_count].
   oe_field_meaning_id = od.oe_field_meaning_id,
   reply->orders[order_count].action_sequence_list[as_count].route_and_form[route_and_form_count].
   oe_field_value = od.oe_field_value
  FOOT  oa.action_sequence
   stat = alterlist(reply->orders[order_count].action_sequence_list[as_count].route_and_form,
    route_and_form_count)
  FOOT  oa.order_id
   stat = alterlist(reply->orders[order_count].action_sequence_list,as_count)
  FOOT REPORT
   stat = alterlist(reply->orders,order_count)
  WITH nocounter
 ;end select
 IF (order_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
