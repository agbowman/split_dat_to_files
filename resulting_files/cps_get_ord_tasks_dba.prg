CREATE PROGRAM cps_get_ord_tasks:dba
 SET count1 = 0
 SET count2 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->order_list,5))
 SELECT INTO "nl:"
  ta.order_id, o.order_id
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   task_activity ta,
   orders o
  PLAN (d)
   JOIN (ta
   WHERE (ta.order_id=request->order_list[d.seq].order_id)
    AND ta.active_ind=1)
   JOIN (o
   WHERE ta.order_id=o.order_id
    AND o.active_ind=1)
  ORDER BY ta.order_id
  HEAD REPORT
   count1 = 0
  HEAD ta.order_id
   count2 = 0, count1 = (count1+ 1)
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].order_id = ta.order_id, reply->get_list[count1].updt_cnt = o.updt_cnt,
   reply->get_list[count1].catalog_cd = o.catalog_cd,
   reply->get_list[count1].catalog_type_cd = o.catalog_type_cd
  DETAIL
   count2 = (count2+ 1)
   IF (count2 > size(reply->get_list[count1].status_list,5))
    stat = alterlist(reply->get_list[count1].status_list,(count2+ 10))
   ENDIF
   reply->get_list[count1].status_list[count2].task_status_cd = ta.task_status_cd
  FOOT  ta.order_id
   stat = alterlist(reply->get_list[count1].status_list,count2)
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH check
 ;end select
 FOR (x = 1 TO count1)
   CALL echo(build("order_id =",reply->get_list[x].order_id))
   SET count1 = size(reply->get_list[x].status_list,5)
   CALL echo(build("x =",x,"  OECount=",count2))
   FOR (y = 1 TO count2)
     CALL echo(build("task_status_cd=",reply->get_list[x].status_list[y].task_status_cd))
   ENDFOR
 ENDFOR
 CALL echo(build("curqual =",curqual))
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("status =",reply->status_data.status))
END GO
