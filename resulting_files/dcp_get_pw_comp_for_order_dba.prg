CREATE PROGRAM dcp_get_pw_comp_for_order:dba
 RECORD reply(
   1 order_cnt = i2
   1 order_qual[*]
     2 order_id = f8
     2 comp_cnt = i2
     2 comp_qual[*]
       3 pathway_id = f8
       3 act_pw_comp_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET order_cnt = 0
 SET comp_cnt = 0
 SELECT INTO "nl:"
  apc.parent_entity_id, apc.parent_entity_name, apc.person_id
  FROM act_pw_comp apc,
   (dummyt d1  WITH seq = value(request->order_cnt))
  PLAN (d1)
   JOIN (apc
   WHERE (apc.parent_entity_id=request->order_qual[d1.seq].order_id)
    AND apc.parent_entity_name="ORDERS")
  HEAD apc.parent_entity_id
   comp_cnt = 0, order_cnt = (order_cnt+ 1)
   IF (order_cnt > size(reply->order_qual,5))
    stat = alterlist(reply->order_qual,(order_cnt+ 5))
   ENDIF
   reply->order_qual[order_cnt].order_id = apc.parent_entity_id
  DETAIL
   comp_cnt = (comp_cnt+ 1)
   IF (comp_cnt > size(reply->order_qual[order_cnt].comp_qual,5))
    stat = alterlist(reply->order_qual[order_cnt].comp_qual,(comp_cnt+ 5))
   ENDIF
   reply->order_qual[order_cnt].comp_qual[comp_cnt].pathway_id = apc.pathway_id, reply->order_qual[
   order_cnt].comp_qual[comp_cnt].act_pw_comp_id = apc.act_pw_comp_id
  FOOT  apc.parent_entity_id
   reply->order_qual[order_cnt].comp_cnt = comp_cnt, stat = alterlist(reply->order_qual[order_cnt].
    comp_qual,comp_cnt)
  WITH nocounter
 ;end select
 SET reply->order_cnt = order_cnt
 SET stat = alterlist(reply->order_qual,order_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
