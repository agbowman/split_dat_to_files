CREATE PROGRAM dcp_srv_get_ord_loc:dba
 RECORD reply(
   1 order_locn_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "S"
 SELECT INTO "NL:"
  o.order_locn_cd
  FROM order_action o
  WHERE (o.order_id=request->order_id)
   AND o.action_sequence=1
  DETAIL
   reply->order_locn_cd = o.order_locn_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
