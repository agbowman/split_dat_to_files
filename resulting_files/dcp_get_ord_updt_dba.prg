CREATE PROGRAM dcp_get_ord_updt:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->order_list,5))
 SELECT INTO "nl:"
  o.order_id
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->order_list[d.seq].order_id)
    AND o.active_ind=1)
  ORDER BY o.order_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].order_id = o.order_id, reply->get_list[count1].updt_cnt = o.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
