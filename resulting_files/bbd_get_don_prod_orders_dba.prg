CREATE PROGRAM bbd_get_don_prod_orders:dba
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 format_id = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  o.synonym_id
  FROM orders o
  PLAN (o
   WHERE (o.product_id=request->product_id))
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].order_id = o.order_id,
   reply->qual[count].format_id = o.oe_format_id, reply->qual[count].catalog_type_cd = o
   .catalog_type_cd, reply->qual[count].catalog_cd = o.catalog_cd
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
